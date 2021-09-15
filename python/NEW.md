RPi
---

Program <> to initialize BT, then read the timer and
set the advertising.


Advertisement
-------------

See https://circuitdigest.com/microcontroller-projects/turn-your-raspberry-pi-into-bluetooth-beacon-using-eddystone-ble-beacon

Header:
0x08 0x0008
<total bytes to follow>
0x02 0x01 0x06  - length, flags data type value, flags data
0x03 0x03 <0x0000> length, complete list of services, 16 bit service (Eddystone eaff)
Data:
<2: run> <3: track 1> <3: track 2> <3: track 3> <3: track 4> <3: track 5> <3: track 6>

possible:
0x1101 - serial port (look up how)


iOS
---

<Pinewood Derby> to scan the BT advertisements and
run the race

1) car number input




