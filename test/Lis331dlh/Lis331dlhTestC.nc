  #include "LIS331DLH.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Lis331dlhTestC {
  uses interface Boot;
  uses interface SplitControl as Lis331SplitControl;
  uses interface Timer<TMilli> as AccelerometerTimer;
  uses interface Read<Accel_t> as AccelerometerAccelRead;
}

implementation {

  Accel_t accel_data;
  uint32_t timer_rate = 100;

  event void Boot.booted() {
    printf("Booted\n");
    call Lis331SplitControl.start();
  }

event void Lis331SplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Lis331 started\n");
      call AccelerometerTimer.startPeriodic(timer_rate);
    } else {
      call Lis331SplitControl.start();
      }

    }

  event void AccelerometerTimer.fired() {
    call AccelerometerAccelRead.read();
    printf("A: ");
    printf("%6d %6d %6d ", accel_data.x, accel_data.y, accel_data.z);
   }

  event void Lis331SplitControl.stopDone(error_t err) {  }

  event void AccelerometerAccelRead.readDone(error_t err, Accel_t val) {
    accel_data = val;
  }

}