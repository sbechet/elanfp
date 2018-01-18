elanfp
======

POC for [Elan driver](https://github.com/iafilatov/libfprint/) generalisation

Vendor: 0x04f3

hardware report
===============

| id     | size    | firmware | who
| ------ | ------- | -------- | ----
| 0x0903 | 96x96   | 1.53     | Sebastien Bechet
| 0x0907 | 144x64  | ?        | Igor Filatov
| 0x0c03 | 96x96   | ?        | Konata Izumi
| 0x0c16 | ?       | ?        | Hans de Goede
| 0x0c1a | ?       | ?        | timo@TeEmZe

fact about reset and fuse load
==============================

* Never see in windows drivers
* Can it be useful after hibernation on suspension?
* What are the cases where these commands are useful?

Q: `Elan_FP_Rest_calibration.pdf` informs us about the reset _and_ the calibration. Should we reset before calibration?

fact about break condition for calibration
==========================================

# 0x01|NOK && 0x03|OK

* Working for: 0x0907, 0x0c16
* Not working for: 0x0903

Q: Is the current `elanfp.c#calibration` version work for every version?

Questions for KT@Elan
=====================

* Can we have usd-id full list?
* Can we use firmware version to know differences beetween commandset?
* Is it possible to have the documentation of the commands according to the firmware version?
