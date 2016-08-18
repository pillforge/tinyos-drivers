/******************************************************************************
Filename: Mpl115a1.h
Pressure and Temperature Driver
Arthur Binstein
8/4/16
******************************************************************************/
#ifndef MPL115A1_H
#define MPL115A1_H

#define WHO_AM_I 0x0C
#define MPL_DEVICE_ID 0x00

typedef struct Coeff_t {
	int16_t a0;
	int16_t b1;
    int16_t b2;
    int16_t c12;
} Coeff_t;

typedef nx_struct PT_t {
	nx_uint16_t PresI;
	// nx_uint16_t PresD;
} PT_t;

#ifndef DUMMY
#define DUMMY     0x00;
#endif

#define Padc_MSB 0x00
#define Padc_LSB 0x01
#define Tadc_MSB 0x02
#define Tadc_LSB 0x03
#define a0_MSB   0x04
#define a0_LSB   0x05
#define b1_MSB   0x06
#define b1_LSB   0x07
#define b2_MSB   0x08
#define b2_LSB   0x09
#define c12_MSB  0x0A
#define c12_LSB  0x0B
#define START_CONVERSION 0x24

#endif
