/*
*App to test I2C with an accelerometer
* @author Arthur Binstein (arthur.t.binstein@vanderbilt.edu)
*
*/

#include "LIS331DLH.h"
configuration Lis331dlhC {
    provides{
        interface SplitControl;
        interface Read<Accel_t> as AccelRead;
    }

}

implementation {
    components new Msp430UsciSpiA0C() as Spi;
    components MainC;
    components Lis331dlhP;
    components HplMsp430GeneralIOC as GPIO;
    components SerialPrintfC;

    SplitControl = Lis331dlhP.SplitControl;

    Lis331dlhP.SpiByte -> Spi;
    Lis331dlhP.Msp430UsciConfigure <- Spi;
    Lis331dlhP.SpiResource -> Spi;
    Lis331dlhP.AccelCS -> GPIO.Port47;

    AccelRead = Lis331dlhP.AccelRead;
   }
