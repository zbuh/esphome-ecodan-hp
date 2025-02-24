# ESPHome Ecodan heatpump
ESPHome implementation of the CN105 protocal. It can operate as standalone or with slave (melcloud/procon) attached. It includes server control mode, realtime power output estimation and realtime daily energy counters. 

The remote thermostat protocol CNRF is supported by https://github.com/gekkekoe/esphome-ecodan-remote-thermostat. It implements a virtual thermostat that can be linked with any temperature sensor.

# available languages
English (default), Dutch, Italian, French, Spanish. Select the language in `ecodan-esphome.yaml` file. 
If you want to contribute with a translation: copy the file `ecodan-labels-en.yaml` to `ecodan-labels-xx.yaml`, fill in all the labels and submit a pull request.

# proxy mode: run melcloud wifi / procon as slave
It's possible to run a melcloud wifi adapter or procon as slave. The slave unit will function as usual.
[see proxy.md for more information](proxy.md)

# server control + prohibit dhw/heating/cooling enabled by default
In sever control mode, the prohibit flags can be set. You can disable it by commenting the `sever-control.yaml` entry in the `ecodan-esphome.yaml`.

# recommended hardware
If you don't want to solder, use one of the tested boards. [More boards that should be working](https://github.com/SwiCago/HeatPump/issues/13#issuecomment-457897457). It also should work for airco units with cn105 connectors. 

Tested boards

| Board | Link | Notes |
|:---|:----:|:---|
| Heishamon V5 large | https://www.tindie.com/products/thehognl/heishamon-communication-pcb/ | [see proxy.md](proxy.md) |
| M5Stack Atom Lite (ESP32 variants) | https://docs.m5stack.com/en/core/ATOM%20Lite | Grove ports used |
| M5Stack Atom Lite (ESP32 variants) | https://docs.m5stack.com/en/core/ATOM%20Lite | Pins used [example](confs/m5stack-atom-lite-proxy.md) |
| M5Stack Atom Lite S3 (ESP32-S3 variants) | https://docs.m5stack.com/en/core/AtomS3%20Lite | Grove ports used |

Cable
* Get one of the grove female cable and a ST PAP-05V-S connector. Remove one end of the grove connector and replace it with a ST PAP-05V-S connector. Here's an example:
![image](https://github.com/gekkekoe/esphome-ecodan-hp/blob/main/img/m5stack_cn105.jpg?raw=true)

Pin mapping (from left to right)
| grove | cn105 |
|:---|:---|
|pin 1 - black (gnd) | pin 4 - black (gnd) |
|pin 2 - red (5v) | pin 3 - red (5v) |
|pin 3 - white (GPIO 2) | pin 2 - white (Tx) |
|pin 4 - yellow (GPIO 1) | pin 1 - yellow (Rx) |

*Note: pin 5 (12v) on the cn105 is not used.*

# where to buy
atom s3 lite
https://www.digikey.nl/en/products/detail/m5stack-technology-co-ltd/C124/18070571

grove cable (multiple options/lengths available)
https://www.digikey.nl/en/products/detail/seeed-technology-co-ltd/110990036/5482563

JST PAP-05V-S connector
https://www.digikey.nl/en/products/detail/jst-sales-america-inc/PAP-05V-S/759977

# easy install: Download the latest firmware
## Get the factory.bin firmware for initial flash
* Go to https://github.com/gekkekoe/esphome-ecodan-hp/releases/latest and download one of the factory.bin files. 
```
Firmware for Atom S3 (Lite): esp32s3-xx-version.factory.bin (where xx = language)
Firmware for Atom S3 (Lite) with proxy PCB: esp32s3-proxy2-xx-version.factory.bin (where xx = language)
```
* Go to https://web.esphome.io/?dashboard_install (Only works in Chrome or Edge), connect the atom via usb-c and click connect. Chrome will let you select the detected esp. Finally you click install and select the factory.bin firmware (downloaded in previous step) and flash.

* Power the esp via usb-c. The led indicator will turn blue indicating that its in access point mode. Connect to the wifi network `ecodan-heatpump` with password `configesp`. Fill in your wifi credentials and click save. The esp will reboot and the led will become green indicating that the wifi is connected correctly. Disconnect the unit from the computer and connect it to the heatpump via the CN105 connector (don't forget to power down the unit via circuit breaker!).

* You will get notifications if an update is available and its updateable in Home Assistant itself. 

# build esphome-ecodan-hp firmware from source
### Build via cmd line:
* Install ESPHome https://esphome.io/guides/getting_started_command_line.html. (Use [Python <= 3.12](https://github.com/esphome/issues/issues/6558) to avoid build errors on Windows)
    ```console
    python3 -m venv venv
    source venv/bin/activate
    pip3 install wheel
    pip3 install esphome
    ```
* Fill in `secrets.yaml` and copy the `ecodan-esphome.yaml` to your esphome folder and edit the values (*check GPO pins (uart: section), you might need to swap the pins in the config*)
The secrets.yaml should at least contain the following entries:
```
wifi_ssid: "wifi network id"
wifi_password: "wifi password"
```
* Edit the following section in `ecodan-esphome.yaml` to match your configuration (esp board, zone1/zone2, language, server control, enable debug). Default is an esp32-s3 board, 1 zone and english language.

```
packages:
  remote_package:
    url: https://github.com/gekkekoe/esphome-ecodan-hp/
    ref: main
    refresh: always
    files: [ 
            confs/base.yaml,            # required
            confs/request-codes.yaml,   # disable if your unit does not support request codes (service menu)
            confs/esp32s3.yaml,         # confs/esp32.yaml, for regular board
            confs/zone1.yaml,
            ## enable if you want to use zone 2
            #confs/zone2.yaml,
            ## enable label language file
            confs/ecodan-labels-en.yaml,
            #confs/ecodan-labels-nl.yaml,
            #confs/ecodan-labels-it.yaml,
            #confs/ecodan-labels-fr.yaml,
            #confs/ecodan-labels-es.yaml,
            confs/server-control.yaml,
            #confs/debug.yaml,
           ]
```

* Build
```console
esphome compile ecodan-esphome.yaml
```
* To find the tty* where the esp32 is connected at, use `sudo dmesg | grep tty`. On my machine it was `ttyACM0` for usb-c, and `ttyUSB0` for usb-a. `tty.usbmodemxxx` for Mac and `COMXX` for Windows

* Connect your esp32 via usb and flash
```console 
esphome upload --device=/dev/ttyACM0 ecodan-esphome.yaml
```
* You can update the firmware via the web interface of the esp after the initial flash, or use the following command to flash over the network
```console 
esphome upload --device ip_address ecodan-esphome.yaml
```

Here's how it's connected inside the heatpump:

![image](https://github.com/gekkekoe/esphome-ecodan-hp/blob/main/img/m5stack_installed.jpg?raw=true)

The esphome component will be auto detected in Home Assistant:

![image](https://github.com/gekkekoe/esphome-ecodan-hp/blob/main/img/ha-integration.png?raw=true)


[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/gekkekoe)
