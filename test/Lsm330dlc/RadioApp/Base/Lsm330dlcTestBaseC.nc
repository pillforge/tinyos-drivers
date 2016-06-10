#include "Lsm330dlc.h"
#include "Radio.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module Lsm330dlcTestBaseC {
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  uses interface Packet;
  uses interface Receive;
}

implementation {
  message_t packet;
  Accel_t a_data;
  Gyro_t g_data;

  task void print () {
    printf("A & G: ");
    printf("%6d %6d %6d ", a_data.x, a_data.y, a_data.z);
    printf("%6d %6d %6d\n", g_data.x, g_data.y, g_data.z);
  }

  event void Boot.booted() {
    printf("Base booted: Lsm330dlcTestBaseC\n");
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      printf("Base radio started.\n");
    } else {
      call RadioControl.start();
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    RadioDataMsg *rdm = (RadioDataMsg *) payload;
    a_data = rdm->a_data;
    g_data = rdm->g_data;
    post print();
    return bufPtr;
  }

  event void RadioControl.stopDone(error_t err) {}
}
