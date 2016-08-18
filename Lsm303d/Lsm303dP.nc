/**
 * lsm303d: Accelerometer + Magnetometer
 */

module Lsm303dP {
    uses {
        interface SpiByte;
        interface Resource as SpiResource;
        interface HplMsp430GeneralIO as AccelCS;
        interface HplMsp430GeneralIO as MagnetCS;
    }
    provides {
        interface Read<Accel_t> as AccelRead;
        interface Read<Magnet_t> as MagnetRead;
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
void ReadMagnetValues();

bool reading_accel = FALSE;
bool reading_magnet = FALSE;

Accel_t accel;   // 3 axes, 2 bytes each
Magnet_t magnet; // 3 axes, 2 bytes each

enum {
    STATE_IDLE = 0,
    STATE_INIT,
    STATE_FAIL
};

uint8_t state = STATE_IDLE;
command error_t SplitControl.start() {
    state = STATE_INIT;
    call AccelCS.set();
    call MagnetCS.set();
    call SpiResource.request();
    return SUCCESS;
}

command error_t Init.init() {
    call AccelCS.makeOutput();
    call AccelCS.set();
    call MagnetCS.makeOutput();
    call MagnetCS.set();
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

uint8_t readRegisterMagnet (uint8_t addr) {
    uint8_t rc;
    call MagnetCS.clr();
    call SpiByte.write((1<<7) |  (addr & 0x7f));
    rc =  call SpiByte.write(0);
    call MagnetCS.set();
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
                if (who_am_i == LSM303D_DEVICE_ID) {
                    // Configure Accelerometer for 400 Hz
                    call AccelCS.clr();
                    writeRegister(CTRL1_A, CTRL1_A_SET);
                    call AccelCS.set();
                    call MagnetCS.clr();
                    writeRegister(CTRL5_M, CTRL5_M_SET);
                    call MagnetCS.set();
                    call MagnetCS.clr();
                    writeRegister(CTRL7_M, CTRL7_M_SET);
                    call MagnetCS.set();

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
                    if (reading_magnet) {
                        ReadMagnetValues();
                        reading_magnet = FALSE;
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

command error_t MagnetRead.read() {
    if (reading_magnet) {
    return FAIL;
    } else {
    reading_magnet = TRUE;
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

void ReadMagnetValues() {
    // Read 6 bytes from accelerometer
    // This can be made more efficient by using the autoincrement
    magnet.x = (int16_t)(((uint16_t) (readRegisterAccel(MAG_REG_OUT_X_H) << 8)) + readRegisterAccel(MAG_REG_OUT_X_L));
    magnet.y = (int16_t)(((uint16_t) (readRegisterAccel(MAG_REG_OUT_Y_H) << 8)) + readRegisterAccel(MAG_REG_OUT_Y_L));
    magnet.z = (int16_t)(((uint16_t) (readRegisterAccel(MAG_REG_OUT_Z_H) << 8)) + readRegisterAccel(MAG_REG_OUT_Z_L));
    signal MagnetRead.readDone(SUCCESS, magnet);
    }

async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
    return &msp430_usci_spi_accel_config;
}

default event void AccelRead.readDone(error_t err, Accel_t val) {
    }

default event void MagnetRead.readDone(error_t err, Magnet_t val) {
    }

default event void SplitControl.stopDone(error_t err) {
    }
}
