#!/usr/bin/python3

import time
import sys

heat = 0

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

  line = sys.stdin

   
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

