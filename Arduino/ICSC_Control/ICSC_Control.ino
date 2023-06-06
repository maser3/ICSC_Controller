// OSC content Created by Fabian Fiess in November 2016
// Inspired by Oscuino Library Examples, Make Magazine 12/2015
// MPU-6050 Mahony AHRS  S.J. Remington 3/2020
// 7/2020 added provision to recalibrate gyro upon startup. (variable cal_gyro)
// Assembled by Shane Byrne 11/22

#include "Wire.h"
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <Smoothed.h>

#define MUX_A D4
#define SW D3
#define ANALOG_INPUT A0

//UDP Stuff

char ssid[] = "<yourSSID>";    // your network SSID (name)
char pass[] = "<yourPassword>";  // your network password

WiFiUDP Udp;                                 // A UDP instance to let us send and receive packets over UDP
const IPAddress destIp(192, 168, 71, 222);  // remote IP of the target device
const unsigned int destPort = 9000;          // remote port of the target device 


int jSW;
Smoothed<int> jX;
Smoothed<int> jY;

////////////////////////////////////////////////////////////////////////////////////////////////////

// MPU Stuff (comments are S.J. Remington's)
int MPU_addr = 0x68;

int cal_gyro = 1;  //set to zero to use gyro calibration offsets below.

// vvvvvvvvvvvvvvvvvv  VERY VERY IMPORTANT vvvvvvvvvvvvvvvvvvvvvvvvvvvvv
//These are the previously determined offsets and scale factors for accelerometer and gyro for
// a particular example of an MPU-6050. They are not correct for other examples.
//The AHRS will NOT work well or at all if these are not correct

float A_cal[6] = { 265.0, -80.0, -700.0, 0.994, 1.000, 1.014 };  // 0..2 offset xyz, 3..5 scale xyz
float G_off[3] = { -499.5, -17.7, -82.0 };                       //raw offsets, determined for gyro at rest
#define gscale ((250. / 32768.0) * (PI / 180.0))                 //gyro default 250 LSB per d/s -> rad/s

// ^^^^^^^^^^^^^^^^^^^ VERY VERY IMPORTANT ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

// GLOBALLY DECLARED, required for Mahony filter
// vector to hold quaternion
float q[4] = { 1.0, 0.0, 0.0, 0.0 };

// Free parameters in the Mahony filter and fusion scheme,
// Kp for proportional feedback, Ki for integral
float Kp = 30.0;
float Ki = 0.0;

// globals for AHRS loop timing
unsigned long now_ms, last_ms = 0;  //millis() timers

// print interval
unsigned long print_ms = 200;  //print angles every "print_ms" milliseconds
float yaw, pitch, roll;        //Euler angle output

void setup() {

  jX.begin(SMOOTHED_AVERAGE, 50);
  jY.begin(SMOOTHED_AVERAGE, 50);

  Wire.begin();
  Serial.begin(115200);
  Serial.println("starting");

  // initialize sensor
  // defaults for gyro and accel sensitivity are 250 dps and +/- 2 g
  Wire.beginTransmission(MPU_addr);
  Wire.write(0x6B);  // PWR_MGMT_1 register
  Wire.write(0);     // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);

  //Joystick Inputs
  pinMode(MUX_A, OUTPUT);
  pinMode(SW, INPUT);

  // WiFi stuff
  WiFi.begin(ssid, pass);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(LED_BUILTIN, HIGH);
    delay(500);
    digitalWrite(LED_BUILTIN, LOW);
  }
}

// AHRS loop

void loop() {

  ////////////////MPU Stuff /////////////////////////////////////////////////////

  static unsigned int i = 0;               //loop counter
  static float deltat = 0;                 //loop time in seconds
  static unsigned long now = 0, last = 0;  //micros() timers
  static long gsum[3] = { 0 };
  //raw data
  int16_t ax, ay, az;
  int16_t gx, gy, gz;
  int16_t Tmp;  //temperature

  //scaled data as vector
  float Axyz[3];
  float Gxyz[3];

  Wire.beginTransmission(MPU_addr);
  Wire.write(0x3B);  // starting with register 0x3B (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_addr, 14, true);  // request a total of 14 registers
  int t = Wire.read() << 8;
  ax = t | Wire.read();  // 0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
  t = Wire.read() << 8;
  ay = t | Wire.read();  // 0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L)
  t = Wire.read() << 8;
  az = t | Wire.read();  // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
  t = Wire.read() << 8;
  Tmp = t | Wire.read();  // 0x41 (TEMP_OUT_H) & 0x42 (TEMP_OUT_L)
  t = Wire.read() << 8;
  gx = t | Wire.read();  // 0x43 (GYRO_XOUT_H) & 0x44 (GYRO_XOUT_L)
  t = Wire.read() << 8;
  gy = t | Wire.read();  // 0x45 (GYRO_YOUT_H) & 0x46 (GYRO_YOUT_L)
  t = Wire.read() << 8;
  gz = t | Wire.read();  // 0x47 (GYRO_ZOUT_H) & 0x48 (GYRO_ZOUT_L)

  // calibrate gyro upon startup. SENSOR MUST BE HELD STILL (a few seconds)
  i++;
  if (cal_gyro) {

    gsum[0] += gx;
    gsum[1] += gy;
    gsum[2] += gz;
    if (i == 500) {
      cal_gyro = 0;  //turn off calibration and print results

      for (char k = 0; k < 3; k++) G_off[k] = ((float)gsum[k]) / 500.0;

      Serial.print("G_Off: ");
      Serial.print(G_off[0]);
      Serial.print(", ");
      Serial.print(G_off[1]);
      Serial.print(", ");
      Serial.print(G_off[2]);
      Serial.println();
    }
  }

  // normal AHRS calculations

  else {
    Axyz[0] = (float)ax;
    Axyz[1] = (float)ay;
    Axyz[2] = (float)az;

    //apply offsets and scale factors from Magneto
    for (i = 0; i < 3; i++) Axyz[i] = (Axyz[i] - A_cal[i]) * A_cal[i + 3];

    Gxyz[0] = ((float)gx - G_off[0]) * gscale;  //250 LSB(d/s) default to radians/s
    Gxyz[1] = ((float)gy - G_off[1]) * gscale;
    Gxyz[2] = ((float)gz - G_off[2]) * gscale;

    //  snprintf(s,sizeof(s),"mpu raw %d,%d,%d,%d,%d,%d",ax,ay,az,gx,gy,gz);
    //  Serial.println(s);

    now = micros();
    deltat = (now - last) * 1.0e-6;  //seconds since last update
    last = now;

    Mahony_update(Axyz[0], Axyz[1], Axyz[2], Gxyz[0], Gxyz[1], Gxyz[2], deltat);

    // Compute Tait-Bryan angles.
    // In this coordinate system, the positive z-axis is down toward Earth.
    // Yaw is the angle between Sensor x-axis and Earth magnetic North
    // (or true North if corrected for local declination, looking down on the sensor
    // positive yaw is counterclockwise, which is not conventional for NED navigation.
    // Pitch is angle between sensor x-axis and Earth ground plane, toward the
    // Earth is positive, up toward the sky is negative. Roll is angle between
    // sensor y-axis and Earth ground plane, y-axis up is positive roll. These
    // arise from the definition of the homogeneous rotation matrix constructed
    // from quaternions. Tait-Bryan angles as well as Euler angles are
    // non-commutative; that is, the get the correct orientation the rotations
    // must be applied in the correct order which for this configuration is yaw,
    // pitch, and then roll.
    // http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
    // which has additional links.

    roll = atan2((q[0] * q[1] + q[2] * q[3]), 0.5 - (q[1] * q[1] + q[2] * q[2]));
    pitch = asin(2.0 * (q[0] * q[2] - q[1] * q[3]));
    //conventional yaw increases clockwise from North. Not that the MPU-6050 knows where North is.
    yaw = -atan2((q[1] * q[2] + q[0] * q[3]), 0.5 - (q[2] * q[2] + q[3] * q[3]));
    // to degrees
    yaw *= 180.0 / PI;
    if (yaw < 0) yaw += 360.0;  //compass circle
    //ccrrect for local magnetic declination here
    pitch *= 180.0 / PI;
    roll *= 180.0 / PI;

    now_ms = millis();  //time to print?
    if (now_ms - last_ms >= print_ms) {
      last_ms = now_ms;
      // print angles for serial plotter...
      //  Serial.print("ypr ");
      //Serial.print(yaw, 0);
      // Serial.print(", ");
      //Serial.println(pitch, 0);
      // Serial.print(", ");
      // Serial.println(roll, 0);
    }
  }


  /////////////Joystick stuff///////////////////////////////////////////////////////////

  changeMux(LOW, LOW, LOW);
  jX.add(analogRead(ANALOG_INPUT));

  //jX = smoothing(ANALOG_INPUT, 10); //Value of the sensor connected Option 0 pin of Mux
  //int jX = smoothing(ANALOG_INPUT, 10);
  changeMux(LOW, LOW, HIGH);
  jY.add(analogRead(ANALOG_INPUT));  //Value of the sensor connected Option 1 pin of Mux
  //jY = smoothing(jY, 10);
  jSW = digitalRead(SW);  //Switch state



  /////////////Add OSC messages

  int abs_pitch = pitch + 90;
  int abs_roll = roll+180;
  //Serial.println(abs_roll);

  OSCMessage msg("/Node");

  msg.add(jX.get());
  msg.add(jY.get());
  msg.add(abs(jSW - 1));
  msg.add(yaw);
  msg.add(pitch);
  msg.add(roll);
  msg.add(speed(abs_pitch));
  msg.add(speed(roll));
  msg.add(direction(abs_pitch));
  msg.add(direction(abs_roll));

  Udp.beginPacket(destIp, destPort);
  msg.send(Udp);
  Udp.endPacket();
  msg.empty();
  delay(1);

}
