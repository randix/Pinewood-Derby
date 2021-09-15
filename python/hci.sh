#!/bin/sh

set -x


hciconfig -h
sudo hciconfig hci0 up
sudo hciconfig hci0 leadv 3
sudo hcitool -i hci0 cmd 0x08 0x0008 1c 02 01 06 03 03 aa fe 14 16 aa fe 10 00 02 63 69 72 63 75 69 74 64 69 67 65 73 74 07 00 00 00

#sudo hcitool -i hci0 cmd 0x08 0x0008 1c 02 01 06 03 03 aa fe 14 16 aa fe 10 00 02 63 69 72 63 75 69 74 64 69 68 65 73 74 07 00 00 00
#sudo hcitool -i hci0 cmd 0x08 0x0008 1c 02 01 06 03 03 aa fe 14 16 aa fe 10 00 02 63 69 72 63 75 69 74 64 69 67 65 73 74 07 00 00 00

