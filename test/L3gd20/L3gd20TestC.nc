#include "L3gd20.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module L3gd20TestC {
  uses interface Boot;
  uses interface SplitControl as L3gd20SplitControl;
  uses interface Timer<TMilli> as GyroscopeTimer;
  uses interface Read<Gyro_t> as GyroscopeGyroRead;
}

implementation {

  Gyro_t gyro_data;
  uint32_t timer_rate = 100;

  event void Boot.booted() {
    printf("Booted\n");
    call L3gd20SplitControl.start();
  }

  event void L3gd20SplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("L3gd20 started\n");
      call GyroscopeTimer.startPeriodic(timer_rate);
    } else {
      call L3gd20SplitControl.start();
    }
  }

  event void GyroscopeTimer.fired() {
    call GyroscopeGyroRead.read();
    printf("G: ");
    printf("%6d %6d %6d\n", gyro_data.x, gyro_data.y, gyro_data.z);
  }

  event void L3gd20SplitControl.stopDone(error_t err) {  }

  event void GyroscopeGyroRead.readDone(error_t err, Gyro_t val) {
    gyro_data = val;
  }

}
