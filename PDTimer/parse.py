#!/usr/bin/python3

# parse.py
#
# Rand Dow 28-Dec-2021
#
# Copyright (C) Randix LLC. All rights reserved.
#
# This reads from the serial port and parses the data from the
# microwizard.com Fast Track Model K2
#
# output the raw data to the file "raw.log"
# output the parsed data to "times.csv"

import os
import serial
import time

ser = None
serialPort = '/dev/tty.usbserial-110'	# macOS 12.1
serialPort = '/dev/ttyUSB0'		# linux RPi

raw = None	# file descriptor
rawLog = 'raw.log'

# display character, and get to disk
def display(c):
  raw.write(c)
  raw.flush()		# push the char to the OS
  os.fsync(raw)		# push to disk
  print(c, end='')
  if c == '>':
    print()

def initSerial():
  global raw, ser
  # Open Serial Port
  try:
    ser = serial.Serial(port=serialPort,
                        baudrate=9600,
                        parity=serial.PARITY_NONE,
                        stopbits=serial.STOPBITS_ONE,
                        bytesize=serial.EIGHTBITS)
    raw = open(rawLog, 'a')
    return True
  except:
    print('No serial port!')
    return False

def parseTrack(track):
  timeVal = float(track.split('=')[1][:6])
  if len(track) > 8:	# we have a time and place
    place = track[8]
  else:
    place = '0'		# no place
  if place   == '!':
    place = '1'
  elif place == '"':
    place = '2'
  elif place == '#':
    place = '3'
  elif place == '$':
    place = '4'
  return place, timeVal
  
def parseSerial(trackCars):
  #print(trackCars)
  line = ''
  c = ''
  ready = False
  while not ready:
    # Get the timer output
    while ser.inWaiting() > 0:
      c = ser.read(1).decode('utf-8')
      display(c)
      if c == '@' or c == '>':
        continue
      line += c
      if c == '\r':
        ready = True
        break
     
  #print('Parse...', line)
  tracks = line.split()
  line = ''
  c = ''
  #print(tracks, len(tracks))

  result = []
  for i in range(len(trackCars)):
    place, timeVal = parseTrack(tracks[i])
    print(i, place, timeVal)
    result.append([trackCars[i], place, timeVal])
  print(result)  
  return result

#-----------------

if __name__ == '__main__':

  if initSerial():
     while True:
       parseSerial(["42", "32", "12", "1"])
