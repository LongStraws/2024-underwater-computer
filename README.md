![](/docs/images/kelpie_logo.png)
# Kelpie Robotics - Underwater Computer
![Kelpie Robotics](https://img.shields.io/badge/Kelpie_Robotics-Underwater_Computer-00a99d.svg?style=for-the-badge)

This repository contains files needed to auto-configure dietPi on Raspberry Pi for Kelpie 2024 scope 1.

## Installation:
   1. Download image from this repository's releases.

   2. Write the image onto the Pi's SD card:
      You can use [balenaEtcher](https://etcher.balena.io/) on any system which will decompress and 
      write the image to the SD card. Alternatively on a UNIX-like system you can use `unxz` to 
      decompress the file, and then write it with `dd` after determining the location of the SD card 
      with `lsblk`:
         `sudo dd if=DietKelPi_RPi-ARMv8-Bookworm.img of=/dev/sdX bs=4M status=progress`
      (replace X with the letter of the card).

   3. The image has a default static IP address of 192.168.0.20. This will work with the NAT setup 
      in the bay. If you need to change this, navigate to the boot partition on the SD card (the 
      smallest partition) and in `dietpi.txt` set `AUTO_SETUP_NET_USESTATIC` to `0` to use DHCP, or 
      leave `AUTO_SETUP_NET_USESTATIC` at `1` and assign a different IP address and Gateway.

   4. Insert SD card into the Pi, attach ethernet and power. The Pi will boot up and begin 
      configuration.

   5. Navigate to `192.168.0.20:5000` (or the device IP address if you changed it) and for each 
      camera set the IP address to that of the topside computer (in the bay this is `192.168.0.21`),
      and turn on UDP stream (This only needs to be done once).