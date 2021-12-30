# Pinewood Derby

### (AWANA Grand Prix)

Copyright © 2021 Randall Dow. All rights reserved.

See LICENSE file for license information.

### Introduction

This app will set up the data and operate the running of a Pinewood Derby, or an AWANA Grand Prix, race. The software consists of the iOS App, available on the Apple AppStore, and a Python based timer interface.

The complete system consists of:

- at lease one iOS or iPadOS device (multiple devices may be used by observers), 
- (currently) a **microwizard.com** Fast Track timer device with power supply,
- a computer which can run Python (Windows, Linux, Mac, **Raspberry Pi**, etc.), 
- an RS232 serial to USB cable, 
- and a switch cable (RJ22 connectors) to the start switch.

##### iOS Pinewood-Derby App

The iOS Pinewood-Derby App, available in the Apple AppStore, has two modes, a master mode and an observer mode.

The observer mode allows:

- Viewing of the racers.
- Viewing of the heats.
- Viewing of the times.
- Viewing of the rankings.
- Viewing of the results.
- Connecting to the computer (e.g., Raspberry Pi) timer server.
- Get the race configuration from the Raspberry Pi timer server.

The master mode allows full control of the race, including

- Everything that the observer mode can do, plus:
- Adding, editing, and deleting racers.
- Managing the heats of the race, including entering special heats.
- Editing the resulting times, to enable ignoring false times.
- Sending the configuration to the computer (e.g., Raspberry Pi) timer server.
- Start and Resume Racing.
- Start and Resume Simulation (for testing).

##### Computer (e.g., RaspberryPi) Timer Connection

This will assume in this section that the computer used is a Raspberry Pi, RPi. Pretty much any computer may be used to attach to the timer and send the data to the iPhones and/or iPads. 

The RPi and the iPhones and iPads must be connected to the local WiFi in order to communicate. 

### Technical Detail

If you don't understand how the Internet operates, please skip this section.

The RPi is started and connected to the local WiFi. This will be discussed below in Installation. the file PIN.txt is edited to create a PIN for the iOS application. This ensures that only the race administrator can have access to the master mode.  Then the programs (applications) ***PDServer.py*** and ***timer.py*** are started.

The RPI begins broadcasting a message including the Internet port that it is listening for commands from the iPhones and iPads.

### Installation
