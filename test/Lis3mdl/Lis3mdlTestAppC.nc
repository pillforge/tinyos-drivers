
configuration Lis3mdlTestAppC {
}

implementation {
  components MainC;
  components Lis3mdlTestC as App;
  App.Boot -> MainC;

  components SerialPrintfC;

  components new TimerMilliC() as MagnetometerTimer;
  App.MagnetometerTimer -> MagnetometerTimer;

  components Lis3mdlC as Magnetometer;
  App.Lis3mdlSplitControl -> Magnetometer.SplitControl;
  App.MagnetometerMagnetRead -> Magnetometer.MagnetRead;
}
