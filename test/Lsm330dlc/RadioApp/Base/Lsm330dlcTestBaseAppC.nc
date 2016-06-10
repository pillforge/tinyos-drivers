#include "Lsm330dlc.h"
#include "Radio.h"

configuration Lsm330dlcTestBaseAppC {
}

implementation {
  components MainC;
  components Lsm330dlcTestBaseC as App;
  App.Boot -> MainC;
  components SerialPrintfC;

  components ActiveMessageC;
  App.RadioControl -> ActiveMessageC;
  App.Packet -> ActiveMessageC;
  components new AMReceiverC(AM_RADIO);
  App.Receive -> AMReceiverC;
}
