#include "Lsm330dlc.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Lsm330dlcTestC {
  uses interface Boot;
  uses interface SplitControl as Lsm330SplitControl;
  uses interface Timer<TMilli> as AccelerometerAndGyroscopeTimer;
  uses interface Read<Accel_t> as AccelerometerAndGyroscopeAccelRead;
  uses interface Read<Gyro_t> as AccelerometerAndGyroscopeGyroRead;
}

implementation {

  Accel_t accel_data;
  Gyro_t gyro_data;
  uint32_t timer_rate = 100;

  event void Boot.booted() {
    printf("Booted\n");
    call Lsm330SplitControl.start();
  }

  event void Lsm330SplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Lsm330 started\n");
      call AccelerometerAndGyroscopeTimer.startPeriodic(timer_rate);
    } else {
      call Lsm330SplitControl.start();
    }
  }

  event void AccelerometerAndGyroscopeTimer.fired() {
    call AccelerometerAndGyroscopeAccelRead.read();
    call AccelerometerAndGyroscopeGyroRead.read();
    printf("A & G: ");
    printf("%6d %6d %6d ", accel_data.x, accel_data.y, accel_data.z);
    printf("%6d %6d %6d\n", gyro_data.x, gyro_data.y, gyro_data.z);
  }

  event void Lsm330SplitControl.stopDone(error_t err) {  }

  event void AccelerometerAndGyroscopeAccelRead.readDone(error_t err, Accel_t val) {
    accel_data = val;
  }

  event void AccelerometerAndGyroscopeGyroRead.readDone(error_t err, Gyro_t val) {
    gyro_data = val;
  }

}

