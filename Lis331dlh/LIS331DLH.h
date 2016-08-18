#ifndef LIS331DLH_H
#define LIS331DLH_H

typedef nx_struct Accel_t {
     nx_int16_t x;
     nx_int16_t y;
     nx_int16_t z;

} Accel_t;

#ifndef DUMMY
#define DUMMY     0x00;
#endif

#define I2C_AUTO_INCR 0x80

/******************************************************************************
 * ACCELEROMETER
 * ******************************************************************************/
#define I2C_ADDRESS_A 0b0011001 // LSB is tied high
#define WHO_AM_I               0x0F
#define LIS331DLH_DEVICE_ID    0x32
#define LIS331DLH_DEVICE_SET   0x2F
// Internal registers mapping
#define CTRL_REG1_A 0x20
// CTRL_REG1_A Configuration words
#define POWER_DOWN_MODE_A      0x00
#define NPen_A                 0x20

#define ACC_50_Hz_A            0x00
#define ACC_100_Hz_A           0x08
#define ACC_400_Hz_A           0x10
#define ACC_1000_Hz_A          0x18

#define x_en_A             0x01
#define y_en_A             0x02
#define xy_en_A            0x03
#define z_en_A             0x04
#define xz_en_A            0x05
#define yz_en_A            0x06
#define xyz_en_A           0x07

#define CTRL_REG4_A        0x23
// CTRL_REG4_A Configuration words
#define BLE                 0x70
#define ACC_8G_A            0x30
#define ACC_4G_A            0x10
#define ACC_2G_A            0x00
#define ST_A                0x02
#define ACC_3WIRE_A         0x01
//
#define STATUS_REG_A   (0x27)  // Read Access
//
// Axes accellerometer
#define ACC_REG_OUT_X_L (0x28)
#define ACC_REG_OUT_X_H (0x29)
#define ACC_REG_OUT_Y_L (0x2A)
#define ACC_REG_OUT_Y_H (0x2B)
#define ACC_REG_OUT_Z_L (0x2C)
#define ACC_REG_OUT_Z_H (0x2D)
//
#define XYZ_A  (0x28 | I2C_AUTO_INCR)   // Read All Axes

#endif
