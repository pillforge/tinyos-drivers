#include "Lsm303d.h"

configuration Lsm303dTestAppC {
}

implementation {
  components MainC;
  components Lsm303dTestC as App;
  App.Boot -> MainC;

  components SerialPrintfC;

  components new TimerMilliC() as AccelerometerAndMagnetTimer;
  App.AccelerometerAndMagnetTimer -> AccelerometerAndMagnetTimer;

  components Lsm303dC as AccelerometerAndMagnet;
  App.Lsm303dSplitControl -> AccelerometerAndMagnet.SplitControl;
  App.AccelerometerAndMagnetAccelRead -> AccelerometerAndMagnet.AccelRead;
  App.AccelerometerAndMagnetMagnetRead -> AccelerometerAndMagnet.MagnetRead;
}
