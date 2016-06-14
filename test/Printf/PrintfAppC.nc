configuration PrintfAppC {
}
implementation {
  components MainC, PrintfC as App;
  components SerialPrintfC;
  App.Boot -> MainC;
}

