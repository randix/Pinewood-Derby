#!/usr/bin/python3

import os
import serial
import time

serialPort = '/dev/tty.usbserial-1110'

raw = None
rawOut = 'raw.out'

ser = None


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
    raw = open(rawOut, 'a')
    return True
  except:
    print('No serial port!')
    return False

def parseTrack(track):
  timeVal = float(track.split('=')[1][:6])
  if len(track) > 8:
    place = track[8]
  else:
    place = ' '
  if place == '!':
    place = '1'
  elif place == '"':
    place = '2'
  elif place == '#':
    place = '3'
  elif place == '$':
    place = '4'
  return place, timeVal
  
def parseSerial(heat, trackCars):
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
     
  print('Parse...', line)
  tracks = line.split()
  line = ''
  c = ''
  print(tracks, len(tracks))

  out = heat
  for i in range(len(tracks)):
    place, timeVal = parseTrack(tracks[i])
    print(i, place, timeVal)
    out += ',%s,%s,%0.4f' % (trackCars[i], place, timeVal)
  print(out)  
  return out
     

#-----------------

if __name__ == '__main__':

  if initSerial():
    parseSerial("1", ["42", "32", "12", "1", "-", "-"] )
