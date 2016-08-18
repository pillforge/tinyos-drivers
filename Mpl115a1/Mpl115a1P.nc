/**
 * Mpl115a1 Temperature and Pressure
 */

#include "Mpl115a1.h"

module Mpl115a1P {
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as PT_CS;
    interface Timer<TMilli> as Timer0;
    
  }
  provides {
    interface Read<PT_t> as PTRead;
    interface Msp430UsciConfigure;
    interface SplitControl;
  }
}

implementation {

  const msp430_usci_config_t msp430_usci_spi_accel_config = {
    /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
    /*ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,*/
    ctl0 : UCCKPH | UCMSB | UCMST | UCSYNC,
    ctl1 : UCSSEL__SMCLK,
    br0  : 32,      /* 32x Prescale, 1*2^19 (512 KiHz) */
    br1  : 0,
    mctl : 0,
    i2coa: 0
  };


  void ReadCoeffValues();
  void StartConversion();

 // bool reading_coeff = FALSE;
  bool reading_PT = FALSE;

  Coeff_t coeff; // 3 axes, 2 bytes each
  PT_t PT; // 3 axes, 2 bytes each

  enum {
    STATE_IDLE = 0,
    STATE_INIT,
    STATE_FAIL
  };

  uint8_t state = STATE_IDLE;
  command error_t SplitControl.start() {
    state = STATE_INIT;
    call PT_CS.set();
    call SpiResource.request();
    return SUCCESS;
  }

  command error_t SplitControl.stop() {
    return SUCCESS;
  }

  int8_t readRegisterCoeff (uint8_t addr) {
    int8_t rc;
    call PT_CS.clr();
    call SpiByte.write((1<<7) | (addr & 0x7f));
    rc =  call SpiByte.write(0);
    call PT_CS.set();
    return rc;
  }

  uint8_t readRegisterPT (uint8_t addr) {
    uint8_t rc;
    call PT_CS.clr();
    call SpiByte.write((1<<7) | (addr & 0x7f));
    rc =  call SpiByte.write(0);
    call PT_CS.set();
    return rc;
  }

  uint8_t writeRegister(uint8_t addr, uint8_t val) {
    uint8_t rc;
    call SpiByte.write((addr & 0x7f));
    rc = call SpiByte.write(val);
    return rc;
  }

  void ReadCoeffValues() {

    coeff.a0 = (int16_t)((readRegisterCoeff(a0_MSB) << 8) + (readRegisterCoeff(a0_LSB)));
    coeff.b1 = (int16_t)((readRegisterCoeff(b1_MSB) << 8) + (readRegisterCoeff(b1_LSB)));
    coeff.b2 = (int16_t)((readRegisterCoeff(b2_MSB) << 8) + (readRegisterCoeff(b2_LSB)));
    coeff.c12 = (int16_t)(((readRegisterCoeff(c12_MSB) << 8) + (readRegisterCoeff(c12_LSB))) >> 2);
  }

void StartConversion() {
  call PT_CS.clr();
  writeRegister(START_CONVERSION, 0x00);
  call PT_CS.set();
  call Timer0.startOneShot(2);
}


event void Timer0.fired() {
  int32_t c12v2, a1, a1v1, y2, a2v2, PComp, Pressure;
  uint16_t Pres_raw, Temp_raw;
  Pres_raw = (((readRegisterPT(Padc_MSB) << 8) + (readRegisterPT(Padc_LSB))) >> 6);
  Temp_raw = (((readRegisterPT(Tadc_MSB) << 8) + (readRegisterPT(Tadc_LSB))) >> 6);
  c12v2 = (((int32_t)coeff.c12) * Temp_raw) >> 11;
  a1    = (int32_t)coeff.b1 + c12v2;
  a1v1  = a1 * Pres_raw;
  y2    = (((int32_t)coeff.a0) << 10) + a1v1;
  a2v2  = (((int32_t)coeff.b2) * Temp_raw) >> 1;
  PComp = (y2 + a2v2) >> 9;
  Pressure = (((((int32_t)PComp) * 1041) >> 14) + 800) >> 4;
 // PT.PresD = (((((int32_t)PComp) * 1041) >> 14) + 800) & (0x0000000F);
  PT.PresI = Pressure;
  call SpiResource.release();
  signal PTRead.readDone(SUCCESS, PT);
}

  event void SpiResource.granted() {
    switch (state) {
      case STATE_INIT:
            ReadCoeffValues();
            call SpiResource.release();
            state = STATE_IDLE;
            signal SplitControl.startDone(SUCCESS);
        break;
      default:
        if (reading_PT) {
          StartConversion();
          reading_PT = FALSE;
        }
        break;
    }
  }

  command error_t PTRead.read() {
    if (reading_PT) {
      return FAIL;
    } else {
      reading_PT = TRUE;
      call SpiResource.request();
      return SUCCESS;
    }
  }

   async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
    return &msp430_usci_spi_accel_config;
  }

  default event void PTRead.readDone(error_t err, PT_t val) {
  }

  default event void SplitControl.stopDone(error_t err) {
  }
}

