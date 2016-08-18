/*
 * @author Arthur Binstein arthur.t.binstein@vanderbilt.edu
 *
 */

#include "Lsm303d.h"
configuration Lsm303dC {
  provides{
    interface SplitControl;
    interface Read<Accel_t> as AccelRead;
    interface Read<Magnet_t> as MagnetRead;
  }
}
implementation {
  components new Msp430UsciSpiA0C() as Spi;
  components MainC;
  components Lsm303dP;
  components HplMsp430GeneralIOC as GPIO;
  components SerialPrintfC;

  SplitControl = Lsm303dP.SplitControl;

  Lsm303dP.SpiByte -> Spi;
  Lsm303dP.Msp430UsciConfigure <- Spi;
  Lsm303dP.SpiResource -> Spi;
  Lsm303dP.AccelCS -> GPIO.Port46;
  Lsm303dP.MagnetCS -> GPIO.Port47;

  AccelRead = Lsm303dP.AccelRead;
  MagnetRead = Lsm303dP.MagnetRead;
}
