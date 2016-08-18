#include "Mpl115a1.h"

configuration Mpl115a1TestAppC {
}

implementation {
  components MainC;
  components Mpl115a1TestC as App;
  App.Boot -> MainC;

  components SerialPrintfC;

  components new TimerMilliC() as PT_Timer;
  App.PT_Timer -> PT_Timer;

  components Mpl115a1C as PTSensor;
  App.Mpl115a1SplitControl -> PTSensor.SplitControl;
  App.PresTempRead -> PTSensor.PTRead;
}
