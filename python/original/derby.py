#!/usr/bin/python3

import os
import serial
import time


serialPort = '/dev/tty.usbserial-110'
rawCSV = 'raw.csv'
rawOut = 'raw.out'

raw = open(rawOut, 'a')


# display, and try very hard to get it to disk, every byte that comes in from the timer.
def display(out):
  raw.write(out)
  raw.flush()		# push the char to the OS
  os.fsync(raw)		# push to disk
  print(out, end='')
  if out == '>':
    print()
  


#==== MAIN ====


# Open Serial Port
try:
  ser = serial.Serial(port=serialPort,
                      baudrate=9600,
                      parity=serial.PARITY_NONE,
                      stopbits=serial.STOPBITS_ONE,
                      bytesize=serial.EIGHTBITS)
except:
  print('No serial port!')
  

line = ''
out = ''

while True:

  # Get Heat and Cars on which Track
  cmd = input('> ')
  #print(cmd)
  cmds = cmd.split()
  print(cmds)
  if len(cmds) < 5:
    print('Invalid input. Use <Heat> <Trk1> <Trk2> <Trk3> <Trk4>')
    continue
  heat = int(cmds[0])
  car1 = int(cmds[1])
  car2 = int(cmds[2])
  car3 = int(cmds[3])
  car4 = int(cmds[4])
  print(heat, car1, car2, car3, car4)

  while ser.inWaiting() > 0:
    out = ser.read(1)
    out = out.decode('utf-8')
    display(out)

  # Get the Timer output
  print('Wait for race...')
  while len(line) == 0:
    while ser.inWaiting() > 0:
      out = ser.read(1)
      out = out.decode('utf-8')
      display(out)
      if out == '@' or out == '>':
        continue
      line += out
      if out == '\r':
        break
      else:
        time.sleep(0.1)
   
  print('Parse...', line)
  stat = line.split()
  line = ''
  out = ''
  print(stat, len(stat))
    
  if len(stat[0]) > 8:
    p1 = stat[0][8]
  else:
    p1 = ' '
  if len(stat[1]) > 8:
    p2 = stat[1][8]
  else:
    p2 = ' '
  if len(stat[2]) > 8:
    p3 = stat[2][8]
  else:
    p3 = ' '
  if len(stat[3]) > 8:
    p4 = stat[3][8]
  else:
    p4 = ' '

  print(p1, p2, p3, p4)
  #    ! " # $

  p1 = p1.replace('!', '1')
  p1 = p1.replace('"', '2')
  p1 = p1.replace('#', '3')
  p1 = p1.replace('$', '4')

  p2 = p2.replace('!', '1')
  p2 = p2.replace('"', '2')
  p2 = p2.replace('#', '3')
  p2 = p2.replace('$', '4')

  p3 = p3.replace('!', '1')
  p3 = p3.replace('"', '2')
  p3 = p3.replace('#', '3')
  p3 = p3.replace('$', '4')

  p4 = p4.replace('!', '1')
  p4 = p4.replace('"', '2')
  p4 = p4.replace('#', '3')
  p4 = p4.replace('$', '4')

  print(p1, p2, p3, p4)

  t1 = float(stat[0].split('=')[1][:6])
  t2 = float(stat[1].split('=')[1][:6])
  t3 = float(stat[2].split('=')[1][:6])
  t4 = float(stat[3].split('=')[1][:6])

   
  print(heat,  car1, p1, t1,  car2, p2, t2,  car3,  p3, t3,  car4, p4, t4)
  # Report and log
  fmtConsole = 'Heat: %2d   %2d %s %6.4f  %2d %s %6.4f  %2d %s %6.4f  %2d %s %6.4f'
  print(fmtConsole % (heat,  car1, p1, t1,  car2, p2, t2,  car3,  p3, t3,  car4, p4, t4))

  csv = open(rawCSV, 'a')
  fmtFile = '%2d,   %2d, %s, %6.4f,  %2d, %s, %6.4f,  %2d, %s, %6.4f,  %2d, %s, %6.4f\n'
  csv.write(fmtFile % (heat,  car1, p1, t1,  car2, p2, t2,  car3,  p3, t3,  car4, p4, t4))
  csv.close()

