#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module PrintfC {
  uses interface Boot;
}
implementation {
  event void Boot.booted() {
    printf("Booted\n");
  }
}

