/******************************************************************************
Filename: l3gd20.h
Gyroscope Driver
Arthur Binstein
7/26/2016
******************************************************************************/
#ifndef L3GD20_H
#define L3GD20_H

typedef nx_struct Gyro_t {
  nx_int16_t x;
  nx_int16_t y;
  nx_int16_t z;
} Gyro_t;

#ifndef DUMMY
#define DUMMY     0x00;
#endif

#define I2C_AUTO_INCR 0x80

/******************************************************************************
GYROSCOPE
******************************************************************************/
#define I2C_ADDRESS_G 0b1101011 // LSB is tied high
#define WHO_AM_I  0x0F
#define L3GD20_DEVICE_ID 0xD4

#define CTRL_REG1_G 0x20
// CTRL_REG1_G Configuration words

#define DRBW_1111  0xF0 // DRBW_1111
#define DRBW_1110  0xE0 // DRBW_1110
#define DRBW_1101  0xD0 // DRBW_1101
#define DRBW_1100  0xC0 // DRBW_1100
#define DRBW_1011  0xB0 // DRBW_1011
#define DRBW_1010  0xA0 // DRBW_1010
#define DRBW_1001  0x90 // DRBW_1001
#define DRBW_1000  0x80 // DRBW_1000
#define DRBW_0111  0x70 // DRBW_0111
#define DRBW_0110  0x60 // DRBW_0110
#define DRBW_0101  0x50 // DRBW_0101
#define DRBW_0100  0x40 // DRBW_0100
#define DRBW_0011  0x30 // DRBW_0011
#define DRBW_0010  0x20 // DRBW_0011
#define DRBW_0001  0x10 // DRBW_0001
#define DRBW_0000  0x00 // DRBW_0000

#define LPen_G            0x08 // low power mode enable

#define x_en_G            0x01
#define y_en_G            0x02
#define xy_en_G           0x03
#define z_en_G            0x04
#define xz_en_G           0x05
#define yz_en_G           0x06
#define xyz_en_G          0x07

#define CTRL_REG4_G       0x23

// CTRL_REG4_G Configuration words
#define BDU                 0x80

#ifndef BLE
#define BLE                 0x70
#endif

#define GYR_2000_dps_2 0x30
#define GYR_2000_dps   0x20
#define GYR_500_dps    0x10
#define GYR_250_dps    0x00
#define GYR_3WIRE_G    0x01

#define STATUS_REG_G  (0x27| 0x80)   // Read Access

#define GYR_REG_OUT_X_L (0x28 | 0x80)
#define GYR_REG_OUT_X_H (0x29 | 0x80)
#define GYR_REG_OUT_Y_L (0x2A | 0x80)
#define GYR_REG_OUT_Y_H (0x2B | 0x80)
#define GYR_REG_OUT_Z_L (0x2C | 0x80)
#define GYR_REG_OUT_Z_H (0x2D | 0x80)

#define XYZ_G  (0x28 | I2C_AUTO_INCR)   // Read All Axes

#endif
