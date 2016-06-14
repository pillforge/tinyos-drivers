#include "Lsm330dlc.h"
#include "Radio.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Lsm330dlcTestC {
  uses interface Boot;
  uses interface SplitControl as RadioSplitControl;
  uses interface SplitControl as Lsm330SplitControl;
  uses interface Packet as RadioPacket;
  uses interface AMSend as RadioAMSend;
  uses interface Timer<TMilli> as AccelerometerAndGyroscopeTimer;
  uses interface Read<Accel_t> as AccelerometerAndGyroscopeAccelRead;
  uses interface Read<Gyro_t> as AccelerometerAndGyroscopeGyroRead;
}

implementation {

  message_t radio_packet;
  uint8_t radio_send_addr = 1;
  task void RadioSendTask();
  Accel_t accel_data;
  Gyro_t gyro_data;
  uint32_t timer_rate = 10;

  event void Boot.booted() {
    printf("Booted\n");
    call RadioSplitControl.start();
  }

  event void RadioSplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Radio started\n");
      call Lsm330SplitControl.start();
    } else {
      call RadioSplitControl.start();
    }
  }

  event void Lsm330SplitControl.startDone(error_t err){
    if (err == SUCCESS) {
      printf("Lsm330 started\n");
      call AccelerometerAndGyroscopeTimer.startPeriodic(timer_rate);
    } else {
      call Lsm330SplitControl.start();
    }
  }

  event void AccelerometerAndGyroscopeTimer.fired() {
    call AccelerometerAndGyroscopeAccelRead.read();
    /*call AccelerometerAndGyroscopeGyroRead.read();*/
    post RadioSendTask();
  }

  event void AccelerometerAndGyroscopeAccelRead.readDone(error_t err, Accel_t val) {
    accel_data = val;
  }

  event void AccelerometerAndGyroscopeGyroRead.readDone(error_t err, Gyro_t val) {
    gyro_data = val;
  }

  task void RadioSendTask() {
    RadioDataMsg* msg = (RadioDataMsg*) call RadioPacket.getPayload(&radio_packet, sizeof(RadioDataMsg));
    msg->a_data = accel_data;
    msg->g_data = gyro_data;
    call RadioAMSend.send(radio_send_addr, &radio_packet, sizeof(RadioDataMsg));
  }

  event void RadioSplitControl.stopDone(error_t err) {
  }

  event void Lsm330SplitControl.stopDone(error_t err) {
  }

  event void RadioAMSend.sendDone(message_t* bufPtr, error_t error) {
  }

}

