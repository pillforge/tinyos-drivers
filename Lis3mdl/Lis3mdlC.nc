/*
 * App to test I2C with a magnetometer
 * @author Arthur Binstein
 *
 */

#include "Lis3mdl.h"
configuration Lis3mdlC {
  provides{
    interface SplitControl;
    interface Read<Magnet_t> as MagnetRead;
  }
}
implementation {
  components new Msp430UsciSpiA0C() as Spi;
  components MainC;
  components Lis3mdlP;
  components HplMsp430GeneralIOC as GPIO;
  components SerialPrintfC;

  SplitControl = Lis3mdlP.SplitControl;

  Lis3mdlP.SpiByte -> Spi;
  Lis3mdlP.Msp430UsciConfigure <- Spi;
  Lis3mdlP.SpiResource -> Spi;
  Lis3mdlP.MagnetCS -> GPIO.Port47;

  MagnetRead = Lis3mdlP.MagnetRead;
}
