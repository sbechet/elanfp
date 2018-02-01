elanfp
======

POC for [Elan driver](https://github.com/iafilatov/libfprint/) generalisation. Please do not use elanfp but Igor driver for test.

Vendor: 0x04f3

Devices ID: 0x0903 ,0x0907, 0x0C01~0x0C33

hardware report
===============

| id     | size    | firmware | who              | Note                                     |
| ------ | ------- | -------- | ---------------- | ---------------------------------------- |
| 0x0903 | 96x96   | 0x0135   | Sebastien Bechet | Two FW : 0x0135 and 0x0142               |
| 0x0907 | 144x64  | 0x0141   | Igor Filatov     |                                          |
| 0x0c03 | 96x96   | ?        | Konata Izumi     |                                          |
| 0x0c16 | 96x96   | 0x0138   | Hans de Goede    |                                          |
| 0x0c1a | 144x64  | 0x0142   | timo@TeEmZe      | 0x40,0x31 before 0x40,0x3F               |
| 0x0c26 | 144x64  | 0x0140   | Hans de Goede    |                                          |

fact about reset and fuse load
==============================

* Never see in windows drivers
* Can it be useful after hibernation on suspension?
* What are the cases where these commands are useful?

Q: `Elan_FP_Rest_calibration.pdf` informs us about the reset _and_ the calibration. Should we reset before calibration?

FK_USB_Command
==============

| Type      | Command name                   | EP1 (Out) Opcode Byte0 | EP1 (Out) Opcode Byte1 | EP1 (Out) Parameters Byte2~N | Reply (EP2,EP3 IN) Endpoint | Reply (EP2,EP3 IN) Reply Data Byte0~N             | FW       | Description                                                                                                       |
|-----------|--------------------------------|------------------------|------------------------|------------------------------|-----------------------------|---------------------------------------------------| -------- | ------------------------------------------------------------------------------------------------------------------|
| Get       | Image Data                     | 0x00                   | 0x09                   | (None)                       | EP2                         | Image Data                                        |          | Get Sensor Image (ADC Value)                                                                                      |
| Set       | Stop and turn off the LED      | 0x00                   | 0x0B                   | (None)                       | (None)                      | (None)                                            |          | Stop PreScan                                                                                                      |
| Get       | Get Image Size                 | 0x00                   | 0x0C                   | (None)                       | EP3                         | Image Width, 0x00, Image Height, 0x00 (4 bytes)   |          | ReadFP Sensor Size(Length, Width)                                                                                 |
| Set       | FP Sensor Reset (Sensor Reset) | 0x40                   | 0x11                   | (None)                       | (None)                      | (None)                                            | > 0x0135 | FP Sensor Reset FP Sensr Reset command is needs a delay (5ms). It can execute next command. (_not_ useful)        |
| Get       | FP Status                      | 0x40                   | 0x13                   | (None)                       | EP3                         | FP Status                                         |          | Execute FP Sensor instruction "Read Sensor Status value" (Execute FP Sensor instruction; 0x03)                    |
| Set       | Fuse_load                      | 0x40                   | 0x14                   | (None)                       | (None)                      | (None)                                            | > 0x0135 | Execute FP Sensor instruction "Fuse load" (Execute FP Sensor instruction 0x04) (_not_ useful)                     |
| Get       | Get FwVer                      | 0x40                   | 0x19                   | (None)                       | EP3                         | FWVer_H, FWVer_L (2 bytes)                        |          | FP Bridge FW Version                                                                                              |
| Get       | Get SensorCmd                  | 0x40                   | 0x21                   | Sensor command (1 byte)      | EP3                         | Read Sensor Command Value from FP sensor (1 byte) |          | Read Sensor Command Value from FP sensor                                                                                     |
| Set       | Set SensorCmd                  | 0x40                   | 0x22                   | Sensor command (1 byte)      | (None)                      | (None)                                            |          | Write Sensor Command to FP sensor                                                                                            |
| Set (Get) | Run Calibration                | 0x40                   | 0x23                   | (None)                       | EP3                         | Status (1byte) 0x01 = Busy, 0x03 = Ok             | > 0x0138 | Sensor Calibration (need retry until Reply OK (0x03) (Retry Interval 50ms).                                                  |
| Get       | Get CalibrationMean            | 0x40                   | 0x24                   | (None)                       | EP3                         | Mean_H, Mean_L (2 bytes)                          | > 0x0138 | Calibration Image mean value                                                                                                 |
| Set       | Turn on the LED                | 0x40                   | 0x31                   | (None)                       | (None)                      | (None)                                            |          | Turn on the LED on 0xC1A                                                                                                     |
| Get       | Pre-Scan                       | 0x40                   | 0x3F                   | (None)                       | EP3                         | Status (1 byte) 0x55 = Object                     |          | Execute FP Pre-Scan (Detect Object on FP Sensor) (It needs polling return value until getting FP reply value from Endpoint3) |
| Get       | Get Reg Data                   | 0x40                   | 0x40~0x7F              | (None)                       | EP3                         | Reg Data (1 byte)                                 |          | Get FP Sensor Register Command                                                                                               |
| Set       | Set Reg                        | 0x40                   | 0x40~0xBF              | Reg Data (1 byte)            | (None)                      | (None)                                            |          | Set FP Sensor Register Command                                                                                               |

Image
=====

Elan FP Sensor provide  14bit ADC resolution  (Range 0~ 16383)  and   its format is  2 bytes/one pixel.

For   2^ 14 to 2^8 resolution down grade . Elan suggest using non-linear Normalize algorithm.

For example

![Non-linear Normalize ( Current Image [x][y] –Background [x][y])](image03.jpg)

Calibration Flow
================

[ELAN] Correct Flow :  0x4023 --> wait 50 ms --> read, check ->0x4023 --> wait 50 ms --> read, check … ( until device reply  0x03 value)

Linux USB RIP
=============

```
# modprobe usbmon
# tshark -D
# tshark -i usbmon0 -w rip.pcap
```

It is then possible to launch windows in a virtual machine by attaching the usb to it.
