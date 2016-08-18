#include "L3gd20.h"

configuration L3gd20TestAppC {
}

implementation {
  components MainC;
  components L3gd20TestC as App;
  App.Boot -> MainC;

  components SerialPrintfC;

  components new TimerMilliC() as GyroscopeTimer;
  App.GyroscopeTimer -> GyroscopeTimer;

  components L3gd20C as Gyroscope;
  App.L3gd20SplitControl -> Gyroscope.SplitControl;
  App.GyroscopeGyroRead -> Gyroscope.GyroRead;
}
