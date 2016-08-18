/*
 * App to test I2C with an PT sensor
 * @author Arthur T Binstein (arthur.t.binstein@vanderbilt.edu)
 *
 */

#include "Mpl115a1.h"
configuration Mpl115a1C {
  provides{
    interface SplitControl;
    interface Read<PT_t> as PTRead;
  }
}
implementation {
  components new Msp430UsciSpiA0C() as Spi;
  components MainC;
  components Mpl115a1P;
  components HplMsp430GeneralIOC as GPIO;
  components SerialPrintfC;
  components new TimerMilliC() as Timer0;

  SplitControl = Mpl115a1P.SplitControl;

  Mpl115a1P.SpiByte -> Spi;
  Mpl115a1P.Msp430UsciConfigure <- Spi;
  Mpl115a1P.SpiResource -> Spi;
  Mpl115a1P.PT_CS -> GPIO.Port47;
  Mpl115a1P.Timer0 -> Timer0;

  PTRead = Mpl115a1P.PTRead;
}
