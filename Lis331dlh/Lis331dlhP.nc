/**
 * lis331dlh: Accelerometer
 */

 // #include "LIS331DLH.h"

module Lis331dlhP {
    uses {
        interface SpiByte;
        interface Resource as SpiResource;
        interface HplMsp430GeneralIO as AccelCS;
    }
    provides {
        interface Read<Accel_t> as AccelRead;
        interface Msp430UsciConfigure;
        interface SplitControl;
        interface Init;
    }
}

implementation {
 
    const msp430_usci_config_t msp430_usci_spi_accel_config = {
    /* Inactive high MSB-first 8-bit 3-pin master driven by SMCLK */
    /*ctl0 : UCCKPL | UCMSB | UCMST | UCSYNC,*/
    ctl0 : UCCKPH | UCMSB | UCMST | UCSYNC,
    ctl1 : UCSSEL__SMCLK,
    br0  : 16,      /* 32x Prescale, 1*2^19 (512 KiHz) */
    br1  : 0,
    mctl : 0,
    i2coa: 0
    };

void ReadAccelValues();

bool reading_accel = FALSE;

Accel_t accel; // 3 axes, 2 bytes each

enum {
    STATE_IDLE = 0,
    STATE_INIT,
    STATE_FAIL
        };

uint8_t state = STATE_IDLE;
command error_t SplitControl.start() {
    state = STATE_INIT;
    call AccelCS.set();
    call SpiResource.request();
    return SUCCESS;
}

command error_t Init.init() {
    call AccelCS.makeOutput();
    call AccelCS.set();
    return SUCCESS;
    }

command error_t SplitControl.stop() {
    return SUCCESS;
}

uint8_t readRegisterAccel (uint8_t addr) {
    uint8_t rc;
    call AccelCS.clr();
    call SpiByte.write((1<<7) |  (addr & 0x7f));
    rc =  call SpiByte.write(0);
    call AccelCS.set();
    return rc;
}

uint8_t writeRegister(uint8_t addr, uint8_t val) {
    uint8_t rc;
    call SpiByte.write((addr & 0x7f));
    rc = call SpiByte.write(val);
    return rc;
}

event void SpiResource.granted() {
    uint8_t who_am_i = 0;
    switch (state) {
        case STATE_INIT:
            who_am_i = readRegisterAccel(WHO_AM_I);
                if (who_am_i == LIS331DLH_DEVICE_ID) {
                    // Configure Accelerometer for 400 Hz
                    call AccelCS.clr();
                    writeRegister(CTRL_REG1_A, LIS331DLH_DEVICE_SET);
                    call AccelCS.set();

                    signal SplitControl.startDone(SUCCESS);
                    call SpiResource.release();
                    state = STATE_IDLE;
                } else {
                    signal SplitControl.startDone(FAIL);
                    state = STATE_FAIL;
                        call SpiResource.release();
                    }
                    break;
                default:
                    if (reading_accel) {
                        ReadAccelValues();
                        reading_accel = FALSE;
                    }
                    call SpiResource.release();
                    break;
                }
            }

command error_t AccelRead.read() {
    if (reading_accel) {
    return FAIL;
  } else {
    reading_accel = TRUE;
    call SpiResource.request();
        return SUCCESS;
    }
}
void ReadAccelValues() {
    // Read 6 bytes from accelerometer
    // This can be made more efficient by using the autoincrement
    accel.x = (int16_t)(((uint16_t) (readRegisterAccel(ACC_REG_OUT_X_H) << 8)) + readRegisterAccel(ACC_REG_OUT_X_L));
    accel.y = (int16_t)(((uint16_t) (readRegisterAccel(ACC_REG_OUT_Y_H) << 8)) + readRegisterAccel(ACC_REG_OUT_Y_L));
    accel.z = (int16_t)(((uint16_t) (readRegisterAccel(ACC_REG_OUT_Z_H) << 8)) + readRegisterAccel(ACC_REG_OUT_Z_L));
    signal AccelRead.readDone(SUCCESS, accel);
    }
async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
    return &msp430_usci_spi_accel_config;
}

default event void AccelRead.readDone(error_t err, Accel_t val) {
    }

default event void SplitControl.stopDone(error_t err) {
    }
}
