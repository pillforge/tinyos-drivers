configuration PrintfAppC {
}
implementation {
  components MainC, PrintfC as App;
  components new TimerMilliC();

  components SerialPrintfC;

  App.Boot -> MainC;
  App.Timer -> TimerMilliC;
}

