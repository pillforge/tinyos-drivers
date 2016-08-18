
configuration Lis331dlhTestAppC {
}

implementation {
  components MainC;
  components Lis331dlhTestC as App;
  App.Boot -> MainC;

  components SerialPrintfC;

  components new TimerMilliC() as AccelerometerTimer;
  App.AccelerometerTimer -> AccelerometerTimer;

  components Lis331dlhC as Accelerometer;
  App.Lis331SplitControl -> Accelerometer.SplitControl;
  App.AccelerometerAccelRead -> Accelerometer.AccelRead;
}
