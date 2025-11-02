# Creality Ender 3 Firmware build

Build system to compile Marlin for Creality Ender3 in a docker container. Ideal for CI systems, but can also be used locally. 

Uses the docker image from https://github.com/shukriadams/docker-platformio

## How to

To build in docker container use

    sh ./build-in-docker

If you have platformio installed locally (f.egs if running in Vagrant) use

    chmod +x build.sh
    ./build.sh

The compiled firmware is Marlin\.pio\build\STM32F103RET6_creality/*.bin. Copy this to an SDcard, put the card in your Ender3 and start it. If you get an an error "EEPROM Verion Error Initialize EEPROM?" select "reset".

Note that printer settings like esteps will be overwritten.