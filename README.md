wiz's installer for FreeBSD 13 on RPI4

WIP! Don't use yet.

Needed:
* Serial console cable connected to GPIO pins
* SSD connected over USB3
* Existing FreeBSD VM to prepare SSD

Notes:
* upgrade eeprom on RPI4 to latest version by flashing empty msdos partition with eeprom release from github repo
* prepare filesystem of SSD using below script to create msdos as first partition and zfs as second partition
* extract rpi everything works tarball to msdos partition (using script)
* extra freebsd 13 to zfs partition (using script)
* edit /etc/fstab and remove both ufs and msdosfs lines
* boot UEFI menu, disable 3GB ram limit, enable device tree

Sources: 
* FreeBSD-13.0-CURRENT-arm64-aarch64-RPI3-20201015-2fa296b785e.img
* https://github.com/raspberrypi/rpi-eeprom/releases
* https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md
* https://github.com/raspberrypi/firmware/tree/master/boot
* https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md
* https://reviews.freebsd.org/D26853
* https://sourceforge.net/projects/rpi4-8gbram-boot-fbsdonly/files/u-boot.bin/download
