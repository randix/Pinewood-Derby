# Pinewood Derby

### (AWANA Grand Prix)

Copyright © 2022 Randix LLC. All rights reserved.

### Introduction

This app will set up the data and operate the running of a Pinewood Derby / Grand Prix electronic timer for a race. The software consists of the iOS App, available on the Apple AppStore, and a Python based timer interface. The Python software can be found in the application directory.

The complete system consists of:

- at lease one iPhone or iPad device (multiple devices may be used by observers), 
- (currently) a **microwizard.com** Fast Track timer device with power supply,
- a computer which can run Python (Windows, Linux, Mac, **Raspberry Pi**, etc.), 
- an RS232 serial to USB cable, 
- and a switch cable (RJ22 connectors) to the start switch.

##### iOS Pinewood-Derby App

The iOS Pinewood-Derby App, available in the Apple AppStore, has two modes, a administrator mode and an observer mode.

The observer mode allows:

- Viewing of the racers.
- Viewing of the heats.
- Viewing of the times.
- Viewing of the rankings.
- Viewing of the results.
- Connecting to the computer (e.g., Raspberry Pi) timer server.
- Getting the race configuration from the Raspberry Pi timer server.

The administrator mode allows full control of the race data, including

- Everything that the observer mode can do, plus:
- Adding, editing, and deleting groups and racers.
- Managing the heats of the race, including entering special heats.
- Editing the resulting times, to allow ignoring false times.
- Sending the configuration to the computer (e.g., Raspberry Pi) timer server.
- Start and resume Racing.
- Start and resume Simulation (for testing).

##### Computer (e.g., RaspberryPi) Timer Connection

This will assume in this section that the computer used is a Raspberry Pi, RPi. Pretty much any computer may be used to attach to the timer and send the data to the iPhones and/or iPads. 

The RPi and the iPhones and iPads must be connected to the local WiFi in order to communicate. 

### Technical Detail

This section details the workings. If you don't understand how the Internet operates, this section is not important.

The RPi is started and connected to the local WiFi. This will be discussed below in Installation. the file PIN.txt is edited to create a PIN for the iOS application. This ensures that only the race administrator can have access to the administration mode.  Then the programs (applications) ***PDServer.py*** and ***timer.py*** are started on the timer computer (RPi).

The RPI has the role of an internet server, the iPads and iPhones communicate with the RPi to fetch data, as well as the administrator informs the RPi of which cars are racing in a given heat.

### Installation

Hardware set-up:

- Assemble the race track with the timer. 

- Connect the start switch cable to the track start switch. 

- Connect the serial cable from the track to the RS232 to USB converter cable and plug that into the RPi (or other timer computer).

- Start the RPi
  
  - Assure that the RPi is connected to the local WiFi. (The RPi makes no use of any available internet connection.)
  
  - Open two windows on the RPi, using the Terminal program.
  
  - Install the Python programs, **PDServer.py** and **timer.py**. (See detail below in Appendix: Timer Server Software Installation).
  
  - Edit the file *PIN.txt* and enter a four digit PIN to be used by the administrator during the race.
  
  - In one window start the **PDServer.py** with the command
    `./PDserver.py`
  
  - In the other window start the **timer.py** with the command
    `./timer.py`

- Start **Pinewood-Derby** on the iPhone or iPad
