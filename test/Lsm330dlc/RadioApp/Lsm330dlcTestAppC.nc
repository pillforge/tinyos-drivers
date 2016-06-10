#include "Lsm330dlc.h"
#include "Radio.h"

configuration Lsm330dlcTestAppC {
}

implementation {
  components MainC;
  components Lsm330dlcTestC as App;
  App.Boot -> MainC;

  components SerialPrintfC;

  components new AMSenderC(AM_RADIO) as RadioAMSenderC;
  components ActiveMessageC as RadioActiveMessageC;
  App.RadioAMSend -> RadioAMSenderC;
  App.RadioSplitControl -> RadioActiveMessageC;
  App.RadioPacket -> RadioActiveMessageC;

  components new TimerMilliC() as AccelerometerAndGyroscopeTimer;
  App.AccelerometerAndGyroscopeTimer -> AccelerometerAndGyroscopeTimer;
  
  components Lsm330dlcC as AccelerometerAndGyroscope;
  App.Lsm330SplitControl -> AccelerometerAndGyroscope.SplitControl;
  App.AccelerometerAndGyroscopeAccelRead -> AccelerometerAndGyroscope.AccelRead;
  App.AccelerometerAndGyroscopeGyroRead -> AccelerometerAndGyroscope.GyroRead;
}

