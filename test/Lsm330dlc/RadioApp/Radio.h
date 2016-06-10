#ifndef RADIO_H
#define RADIO_H


typedef nx_struct RadioDataMsg {
  Accel_t a_data;
  Gyro_t g_data;
} RadioDataMsg;

enum {
  AM_RADIO = 0
};

#endif
