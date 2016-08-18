/******************************************************************************
Filename: l3gd20.h
Magnetometer Driver
Arthur Binstein
8/2/2016
******************************************************************************/
#ifndef LIS3MDL_H
#define LIS3MDL_H

typedef nx_struct Magnet_t {
  nx_int16_t x;
  nx_int16_t y;
  nx_int16_t z;
} Magnet_t;

#ifndef DUMMY
#define DUMMY     0x00;
#endif

#define I2C_AUTO_INCR 0x80

/******************************************************************************
MAGNETOMETER
******************************************************************************/
#define I2C_ADDRESS_G 0b1101011 // LSB is tied high
#define WHO_AM_I  0x0F
#define LIS3MDL_DEVICE_ID 0x3D

#define CTRL_REG1 0x20

// CTRL_REG1_G Configuration words

#define CTRL_REG1_SET  0xE3

#define CTRL_REG3 0x22
#define CTRL_REG3_SET 0x00

#define STATUS_REG_M (0x27| 0x80)   // Read Access

#define MAG_REG_OUT_X_L (0x28 | 0x80)
#define MAG_REG_OUT_X_H (0x29 | 0x80)
#define MAG_REG_OUT_Y_L (0x2A | 0x80)
#define MAG_REG_OUT_Y_H (0x2B | 0x80)
#define MAG_REG_OUT_Z_L (0x2C | 0x80)
#define MAG_REG_OUT_Z_H (0x2D | 0x80)

#define XYZ_M  (0x28 | I2C_AUTO_INCR)   // Read All Axes

#endif
