#include "Lsm303d.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Lsm303dTestC {
  uses interface Boot;
  uses interface SplitControl as Lsm303dSplitControl;
  uses interface Timer<TMilli> as AccelerometerAndMagnetTimer;
  uses interface Read<Accel_t> as AccelerometerAndMagnetAccelRead;
  uses interface Read<Magnet_t> as AccelerometerAndMagnetMagnetRead;
}

implementation {

  Accel_t accel_data;
  Magnet_t magnet_data;
  uint32_t timer_rate = 100;

  event void Boot.booted() {
    printf("Booted\n");
    call Lsm303dSplitControl.start();
  }

  event void Lsm303dSplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Lsm303d started\n");
      call AccelerometerAndMagnetTimer.startPeriodic(timer_rate);
    } else {
      call Lsm303dSplitControl.start();
    }
  }

  event void AccelerometerAndMagnetTimer.fired() {
    call AccelerometerAndMagnetAccelRead.read();
    call AccelerometerAndMagnetMagnetRead.read();
    printf("A & M: ");
    printf("%6d %6d %6d ", accel_data.x, accel_data.y, accel_data.z);
    printf("%6d %6d %6d\n", magnet_data.x, magnet_data.y, magnet_data.z);
  }

  event void Lsm303dSplitControl.stopDone(error_t err) {  }

  event void AccelerometerAndMagnetAccelRead.readDone(error_t err, Accel_t val) {
    accel_data = val;
  }

  event void AccelerometerAndMagnetMagnetRead.readDone(error_t err, Magnet_t val) {
    magnet_data = val;
  }

}

