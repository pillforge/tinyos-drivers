#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module PrintfC {
  uses interface Boot;
  uses interface Timer<TMilli>;
}
implementation {
  event void Boot.booted() {
    printf("Booted\n");
    call Timer.startPeriodic(500);
  }

  event void Timer.fired() {
  printf("working");
 }
}

