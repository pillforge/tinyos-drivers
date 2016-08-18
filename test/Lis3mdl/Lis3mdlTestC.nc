  #include "Lis3mdl.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Lis3mdlTestC {
  uses interface Boot;
  uses interface SplitControl as Lis3mdlSplitControl;
  uses interface Timer<TMilli> as MagnetometerTimer;
  uses interface Read<Magnet_t> as MagnetometerMagnetRead;
}

implementation {

  Magnet_t magnet_data;
  uint32_t timer_rate = 100;

  event void Boot.booted() {
    printf("Booted\n");
    call Lis3mdlSplitControl.start();
  }

event void Lis3mdlSplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Lis3mdl started\n");
      call MagnetometerTimer.startPeriodic(timer_rate);
    } else {
      call Lis3mdlSplitControl.start();
      }

    }

  event void MagnetometerTimer.fired() {
    call MagnetometerMagnetRead.read();
    printf("M: ");
    printf("%6d %6d %6d \n ", magnet_data.x, magnet_data.y, magnet_data.z);
   }

  event void Lis3mdlSplitControl.stopDone(error_t err) {  }

  event void MagnetometerMagnetRead.readDone(error_t err, Magnet_t val) {
    magnet_data = val;
  }

}