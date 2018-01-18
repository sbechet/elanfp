elanfp
======

POC for [Elan driver](https://github.com/iafilatov/libfprint/) generalisation

Vendor: 0x04f3

hardware report
===============

| id     | size    | firmware | Calibration status | who              | Note                       |
| ------ | ------- | -------- | ------------------ | ---------------- | -------------------------- |
| 0x0903 | 96x96   | 1.53     | Mean_H             | Sebastien Bechet |                            |
| 0x0907 | 144x64  | ?        | 0x03 & 0x01        | Igor Filatov     |                            |
| 0x0c03 | 96x96   | ?        | ?                  | Konata Izumi     |                            |
| 0x0c16 | 96x96   | 1.56     | 0x03 & 0x01        | Hans de Goede    |                            |
| 0x0c1a | ?       | ?        | ?                  | timo@TeEmZe      | 0x40,0x31 before 0x40,0x3F |
| 0x0c26 | 64x144  | 1.64     | 0x03 & 0x01        | Hans de Goede    |                            |

fact about reset and fuse load
==============================

* Never see in windows drivers
* Can it be useful after hibernation on suspension?
* What are the cases where these commands are useful?

Q: `Elan_FP_Rest_calibration.pdf` informs us about the reset _and_ the calibration. Should we reset before calibration?

Preparation of questions for KT@Elan
====================================

* Can we have usd-id full list?
* Can we use firmware version to know differences beetween commandset?
* Is it possible to have the documentation of the commands according to the firmware version?


FK_USB_Command 20171215 for 0x0c16
==================================

| Type      | Command name                   | EP1 (Out) Opcode Byte0 | EP1 (Out) Opcode Byte1 | EP1 (Out) Parameters Byte2~N | Reply (EP2,EP3 IN) Endpoint | Reply (EP2,EP3 IN) Reply Data Byte0~N             | Description                                                                                                                  |
|-----------|--------------------------------|------------------------|------------------------|------------------------------|-----------------------------|---------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| Get       | Image Data                     | 0x00                   | 0x09                   | (None)                       | EP2                         | Image Data                                        | Get Sensor Image (ADC Value)                                                                                                 |
| Set       | Stop                           | 0x00                   | 0x0B                   | (None)                       | (None)                      | (None)                                            | Stop PreScan                                                                                                                 |
| Get       | Get Image Size                 | 0x00                   | 0x0C                   | (None)                       | EP3                         | Image Width, 0x00, Image Height, 0x00 (4 bytes)   | ReadFP Sensor Size(Length, Width)                                                                                            |
| Set       | FP Sensor Reset (Sensor Reset) | 0x40                   | 0x11                   | (None)                       | (None)                      | (None)                                            | FP Sensor Reset FP Sensr Reset command is needs a delay (5ms). It can execute next command                                   |
| Get       | FP Status                      | 0x40                   | 0x13                   | (None)                       | EP3                         | FP Status                                         | Execute FP Sensor instruction "Read Sensor Status value" (Execute FP Sensor instruction; 0x03)                               |
| Set       | Fuse_load                      | 0x40                   | 0x14                   | (None)                       | (None)                      | (None)                                            | Execute FP Sensor instruction "Fuse load" (Execute FP Sensor instruction 0x04)                                               |
| Get       | Get FwVer                      | 0x40                   | 0x16                   | (None)                       | EP3                         | FWVer_H, FWVer_L (2 bytes)                        | FP Bridge FW Version                                                                                                         |
| Get       | Get SensorCmd                  | 0x40                   | 0x21                   | Sensor command (1 byte)      | EP3                         | Read Sensor Command Value from FP sensor (1 byte) | Read Sensor Command Value from FP sensor                                                                                     |
| Set       | Set SensorCmd                  | 0x40                   | 0x22                   | Sensor command (1 byte)      | (None)                      | (None)                                            | Write Sensor Command to FP sensor                                                                                            |
| Set (Get) | Run Calibration                | 0x40                   | 0x23                   | (None)                       | EP3                         | Status (1byte) 0x01 = Busy, 0x03 = Ok             | Sensor Calibration (need retry until Reply OK (0x03) (Retry Interval 50ms)                                                   |
| Get       | Get CalibrationMean            | 0x40                   | 0x24                   | (None)                       | EP3                         | Mean_H, Mean_L (2 bytes)                          | Calibration Image mean value                                                                                                 |
| Get       | Pre-Scan                       | 0x40                   | 0x3F                   | (None)                       | EP3                         | Status (1 byte) 0x55 = Object                     | Execute FP Pre-Scan (Detect Object on FP Sensor) (It needs polling return value until getting FP reply value from Endpoint3) |
| Get       | Get Reg Data                   | 0x40                   | 0x40~0x7F              | (None)                       | EP3                         | Reg Data (1 byte)                                 | Get FP Sensor Register Command                                                                                               |
| Set       | Set Reg                        | 0x40                   | 0x40~0xBF              | Reg Data (1 byte)            | (None)                      | (None)                                            | Set FP Sensor Register Command                                                                                               |
