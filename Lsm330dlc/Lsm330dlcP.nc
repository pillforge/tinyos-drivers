/**
 * lsm330dlc: Accelerometer and Gyroscope
 */

#include "Lsm330dlc.h"

module Lsm330dlcP {
  uses {
    interface SpiByte;
    interface Resource as SpiResource;
    interface HplMsp430GeneralIO as AccelCS;
    interface HplMsp430GeneralIO as GyroCS;
  }
  provides {
    interface Read<Accel_t> as AccelRead;
    interface Read<Gyro_t> as GyroRead;
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

  task void ReadGyroValues();
  task void ReadAccelValues();

  Accel_t accel; // 3 axes, 2 bytes each
  Gyro_t gyro; // 3 axes, 2 bytes each

  enum {
    STATE_IDLE = 0,
    STATE_INIT,
    STATE_FAIL,
    STATE_ACCEL,
    STATE_GYRO,
    STATE_BOTH
  };

  uint8_t state = STATE_IDLE;
  command error_t SplitControl.start() {
    state = STATE_INIT;
    call AccelCS.set();
    call GyroCS.set();
    call SpiResource.request();
    return SUCCESS;
  }

  command error_t SplitControl.stop() {
    return SUCCESS;
  }

  uint8_t readRegisterGyro (uint8_t addr) {
    uint8_t rc;
    call GyroCS.clr();
    call SpiByte.write((1<<7) | (addr & 0x7f));
    rc =  call SpiByte.write(0);
    call GyroCS.set();
    return rc;
  }

  uint8_t readRegisterAccel (uint8_t addr) {
    uint8_t rc;
    call AccelCS.clr();
    call SpiByte.write((1<<7) | (addr & 0x7f));
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

  void spiRelease() {
    if (state == STATE_BOTH) {
      state = STATE_ACCEL;
    } else {
      call SpiResource.release();
      state = STATE_IDLE;
    }
  }

  event void SpiResource.granted() {
    uint8_t who_am_i = 0;
    switch (state) {
      case STATE_INIT:
        who_am_i = readRegisterGyro(WHO_AM_I_G);
        if (who_am_i == LSM330DLC_DEVICE_ID) {
          // Configure Accelerometer for 400 Hz, High resolution
          call AccelCS.clr();
          writeRegister(CTRL_REG1_A, ACC_400_Hz_A | xyz_en_A);
          call AccelCS.set();
          call AccelCS.clr();
          writeRegister(CTRL_REG4_A, HR_A | ACC_2G_A);
          call AccelCS.set();

          // Configure Gyro
          call GyroCS.clr();
          writeRegister(CTRL_REG1_G, DRBW_1000 | LPen_G | xyz_en_G);
          call GyroCS.set();

          signal SplitControl.startDone(SUCCESS);
          spiRelease();
        } else {
          signal SplitControl.startDone(FAIL);
          state = STATE_FAIL;
          call SpiResource.release();
        }
        break;
      case STATE_ACCEL:
        post ReadAccelValues();
        break;
      case STATE_GYRO:
        post ReadGyroValues();
        break;
      case STATE_BOTH:
        post ReadAccelValues();
        post ReadGyroValues();
        break;
      default:
        spiRelease();
    }
  }

  command error_t AccelRead.read() {
    if (state == STATE_IDLE) {
      state = STATE_ACCEL;
      call SpiResource.request();
      return SUCCESS;
    } else if (state == STATE_GYRO) {
      state = STATE_BOTH;
      return SUCCESS;
    }
    return FAIL;
  }
  command error_t GyroRead.read() {
    if (state == STATE_IDLE) {
      state = STATE_GYRO;
      call SpiResource.request();
      return SUCCESS;
    } else if (state == STATE_ACCEL) {
      state = STATE_BOTH;
      return SUCCESS;
    }
    return FAIL;
  }

  task void ReadAccelValues() {
    // Read 6 bytes from accelerometer
    // This can be made more efficient by using the autoincrement
    accel.x = (int16_t)(((uint16_t) (readRegisterAccel(ACC_REG_OUT_X_H) << 8)) + readRegisterAccel(ACC_REG_OUT_X_L));
    accel.y = (int16_t)(((uint16_t) (readRegisterAccel(ACC_REG_OUT_Y_H) << 8)) + readRegisterAccel(ACC_REG_OUT_Y_L));
    accel.z = (int16_t)(((uint16_t) (readRegisterAccel(ACC_REG_OUT_Z_H) << 8)) + readRegisterAccel(ACC_REG_OUT_Z_L));
    spiRelease();
    signal AccelRead.readDone(SUCCESS, accel);
  }

  task void ReadGyroValues() {
    // Read 6 bytes from accelerometer
    gyro.x = (int16_t)(((uint16_t) (readRegisterGyro(GYR_REG_OUT_X_H) << 8)) + readRegisterGyro(GYR_REG_OUT_X_L));
    gyro.y = (int16_t)(((uint16_t) (readRegisterGyro(GYR_REG_OUT_Y_H) << 8)) + readRegisterGyro(GYR_REG_OUT_Y_L));
    gyro.z = (int16_t)(((uint16_t) (readRegisterGyro(GYR_REG_OUT_Z_H) << 8)) + readRegisterGyro(GYR_REG_OUT_Z_L));
    spiRelease();
    signal GyroRead.readDone(SUCCESS, gyro);
  }

  async command const msp430_usci_config_t* Msp430UsciConfigure.getConfiguration() {
    return &msp430_usci_spi_accel_config;
  }

  default event void AccelRead.readDone(error_t err, Accel_t val) {
  }

  default event void GyroRead.readDone(error_t err, Gyro_t val) {
  }

  default event void SplitControl.stopDone(error_t err) {
  }
}

