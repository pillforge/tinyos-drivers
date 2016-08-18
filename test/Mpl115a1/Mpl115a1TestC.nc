#include "Mpl115a1.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Mpl115a1TestC {
  uses interface Boot;
  uses interface SplitControl as Mpl115a1SplitControl;
  uses interface Timer<TMilli> as PT_Timer;
  uses interface Read<PT_t> as PresTempRead;
}

implementation {
  PT_t PT_data;
  uint32_t timer_rate = 100;

  event void Boot.booted() {
    printf("Booted\n");
    call Mpl115a1SplitControl.start();
  }

  event void Mpl115a1SplitControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Mpl115a1 started\n");
      call PT_Timer.startPeriodic(timer_rate);
    } else {
      call Mpl115a1SplitControl.start();
    }
  }

  event void PT_Timer.fired() {
    call PresTempRead.read();
    printf("P: ");
    printf("%6d\n", PT_data.PresI);
  }

  event void Mpl115a1SplitControl.stopDone(error_t err) {  }


  event void PresTempRead.readDone(error_t err, PT_t val) {
    PT_data = val;
  }

}

