#!/usr/bin/python3

# Rand Dow, August 2021

import sys
import os

race = 0

while True:

  raw = sys.stdin.readline()
  #print(raw)
  if len(raw) == 0:
    sys.exit(0)
   
  stat = raw.split()
  #print(stat, len(stat))

  # parse the raw line, pulling out the place character
  order = []
  for elem in stat:
    v = elem.split('=')[1]

    place = 0
    position = v[-1]
    if position   == '!':
      place = 1
    elif position == '"':
      place = 2
    elif position == '#':
      place = 3
    elif position == '$':
      place = 4
    # places 5 and 6 symbols are not known by Rand

    # put it into an array for sorting
    if place != 0:
      tim = v[:-1]
      order.append((place, tim))
    order = sorted(order)

  race += 1

  # format to a binary array
  bytes = []
  bytes.append((race >> 8) & 0xff)
  bytes.append((race     ) & 0xff)
  for elem in order:
    print(elem)
    tim = elem[1].replace('.', '')
    bin = int(tim)
    print(tim)
    bytes.append((bin >> 16) & 0xff)
    bytes.append((bin >>  8) & 0xff)
    bytes.append((bin      ) & 0xff)
    print(bytes)

  cmd = "sudo hcitool -i hci0 cmd 0x08 0x0008 "

  flags = [0x02, 0x01, 0x06]
  svc = [0x03, 0x03, 0x01, 0x11]
  svcData = [0x16, 0x01, 0x11]
  l1 = len(flags) + len(svc) +  len(svcData) + len(bytes) + 1
  l2 = len(svcData) + len(bytes)

  final = [l1] + flags + svc + [l2] + svcData + bytes
  c = ""
  for v in final:
    c += "%02X " % (v)
  add = 32 - len(final) 
  print(len(c), add)
  for i in range(add):
    c += "00 "

  cmd += c
  print(cmd)
  os.system(cmd)
