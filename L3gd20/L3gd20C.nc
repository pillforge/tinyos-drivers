/*
 * App to test I2C with a gyroscp[e]
 * @author Arthur Binstein
 *
 */

#include "L3gd20.h"
configuration L3gd20C {
  provides{
    interface SplitControl;
    interface Read<Gyro_t> as GyroRead;
  }
}
implementation {
  components new Msp430UsciSpiA0C() as Spi;
  components MainC;
  components L3gd20P;
  components HplMsp430GeneralIOC as GPIO;
  components SerialPrintfC;

  SplitControl = L3gd20P.SplitControl;

  L3gd20P.SpiByte -> Spi;
  L3gd20P.Msp430UsciConfigure <- Spi;
  L3gd20P.SpiResource -> Spi;
  L3gd20P.GyroCS -> GPIO.Port47;

  GyroRead = L3gd20P.GyroRead;
}
