#!/usr/bin/python3

import os
import serial
import time

serialPort = '/dev/tty.usbserial-110'

rawOut = 'raw.out'

ser = None


# display, and try very hard to get it to disk,
# each byte that comes in from the timer.
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
  time = float(track.split('=')[1][:6])
  if len(track) > 8:
    place = track[8]
  else:
    place = ' '
  if place == '!':
    place = '1'
  else if place == '"':
    place = '2'
  else if place == '#':
    place = '3'
  else if place == '$':
    place = '4'
  return place, time
  
def parseSerial(heat, trackCars):

  line = ''
  c = ''

  while True:
  
    # read any waiting characters
    while ser.inWaiting() > 0:
      c = ser.read(1).decode('utf-8')
      display(c)
  
    # Get the timer output
    print('Wait for race...')
    while len(line) == 0:
      while ser.inWaiting() > 0:
        c = ser.read(1).decode('utf-8')
        display(c)
        if c == '@' or c == '>':
          continue
        line += c
        if c == '\r':
          break
        else:
          time.sleep(0.1)
     
  print('Parse...', line)
  tracks = line.split()
  line = ''
  c = ''
  print(tracks, len(tracks))

  out = heat
  for i in range(len(tracks)):
    place, time = parseTrack(tracks[i])
    out += ',%s,%s,%0.4f' % (trackCars[i], place, time)
  print(out)  
  return out
     

#-----------------

if __name__ == '__main__':

  intiSerial()
  parseSerial()
