#!/usr/bin/env python3

# timer.py
#
# Rand Dow 28-Dec-2021
#
# Copyright (C) Randall Dow. All rights reserved.
#

import parse

import os
import time
import random
import sys

nextheat = "nextheat.csv"
timeslog = "timeslog.csv"
times    = "times.csv"

cars = []       # [car number, firstSim, [track time]]
trackCars = []  # [heat, car number, track time, ...]

def getNextHeat():
  """
  Open and read the nextheat file.
  For simulation set up the 'cars' array.
  """ 
  while True:
    time.sleep(0.2)
    try:
      f = open(nextheat, 'r')
      filedata = f.read()
      f.close()
      os.remove(nextheat)
      data = filedata.split(',')
      for i in range(len(data)):
        data[i] = data[i].strip()
      print("data", data)
      heat = data[0]
      trackCars = []
      for i in range(1, len(data)):
        trackCars.append(data[i])
        found = False
        for j in range(len(cars)):
          if cars[j][0] == data[i]:
            found = True
            break
        if not found:
          cars.append([data[i], 0, [0,0,0,0,0,0]])
      print("trackCars", trackCars)
      print("cars", cars)
      return heat, trackCars
    except:
      continue

def simulate(trackCars):
  result = []
  for i in range(len(trackCars)):
    if trackCars[i] == "0":
      continue
    index = 0
    for j in range(len(cars)):
      if cars[j][0] == trackCars[i]:
        index = j
        break
    if cars[index][1] == 0:
      cars[index][1] = random.uniform(4, 6.3)
      cars[index][2][i] = cars[index][1]
    else:
      cars[index][2][i] = random.uniform(cars[index][1]-0.2, cars[index][1]+0.2)
    # car,place,time, ...
    result.append([trackCars[i], 0, cars[index][2][i]])
  result = sorted(result, key=lambda result: result[2])
  for i in range(len(result)):
    result[i][1] = i+1
  time.sleep(3)
  return result

def output(heat, trackCars, result):
  print('output:', heat, result)
  out = heat
  for i in range(len(trackCars)):
    if trackCars[i] == "0":
      out += ',0,0,0'
      continue
    for j in range(len(result)):
      if result[j][0] == trackCars[i]:
        out += ',%s,%s,%0.4f' % (trackCars[i], result[j][1], result[j][2])
  print(out)
  out += '\n'
  f = open(times+".tmp", 'w')
  f.write(out)
  f.close()
  f = open(timeslog, 'a')
  f.write(out)
  f.close
  os.rename(times+".tmp", times)

def main():
  global cars

  doSimulate = False
  if len(sys.argv) > 1:
    doSimulate = True
    cars = []

  if not doSimulate:
    while True:
      print()
      if not parse.initSerial():
        print("CANNOT OPEN SERIAL PORT TO TRACK TIMER.")
        print("Connect the Timer with serial cable and USB.\n")
        time.sleep(5)
      else:
        break

  while True:
    heat, trackCars = getNextHeat()
    if doSimulate:
      result = simulate(trackCars)
    else:
      result = parse.parseSerial(trackCars) 
    output(heat, trackCars, result)


# ------------------------------

if __name__ == '__main__':
  main()
