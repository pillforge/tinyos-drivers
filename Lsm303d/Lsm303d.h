#ifndef LSM303D_H
#define LSM303D_H

typedef nx_struct Accel_t {
     nx_int16_t x;
     nx_int16_t y;
     nx_int16_t z;

} Accel_t;

typedef Accel_t Magnet_t;

#ifndef DUMMY
#define DUMMY     0x00;
#endif

#define I2C_AUTO_INCR 0x80

/******************************************************************************
 * ACCELEROMETER
 * ******************************************************************************/

#define WHO_AM_I               0x0F
#define LSM303D_DEVICE_ID    0x49

// Internal registers mapping
#define CTRL1_A       0x20
#define CTRL1_A_SET   0x87 // 400 Hz and enable xyz

#define ACC_REG_OUT_X_L (0x28)
#define ACC_REG_OUT_X_H (0x29)
#define ACC_REG_OUT_Y_L (0x2A)
#define ACC_REG_OUT_Y_H (0x2B)
#define ACC_REG_OUT_Z_L (0x2C)
#define ACC_REG_OUT_Z_H (0x2D)
//
#define XYZ_A  (0x28 | I2C_AUTO_INCR)   // Read All Axes

/******************************************************************************
 * MAGNETOMETER
 * ******************************************************************************/
#define CTRL5_M      0x24
#define CTRL5_M_SET  0x70

#define CTRL7_M      0x26
#define CTRL7_M_SET  0x00 //high resolution, continuous conversion

#define MAG_REG_OUT_X_L (0x08)
#define MAG_REG_OUT_X_H (0x09)
#define MAG_REG_OUT_Y_L (0x0A)
#define MAG_REG_OUT_Y_H (0x0B)
#define MAG_REG_OUT_Z_L (0x0C)
#define MAG_REG_OUT_Z_H (0x0D)

#endif
