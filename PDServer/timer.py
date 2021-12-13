#!/usr/bin/env python3

import os
import time
import random
import sys

cars = []       # car number, firstSim, [track time]

nextheat = "nextheat.csv"
timeslog = "timeslog.csv"
times    = "times.csv"

heat = 0
trackCars = []  # this heat, car numbers
result = []

doSimulate = False

def getNextHeat():
  global heat, trackCars
  while True:
    time.sleep(0.2)
    #if True:
    try:
      f = open(nextheat, 'r')
      filedata = f.read()
      f.close()
      data = filedata.split(',')
      for i in range(len(data)):
        data[i] = data[i].strip()
      #print("data", data)
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
      #print("trackCars", trackCars)
      os.remove(nextheat)
      return data
    except:
      #print("except")
      continue

def simulate():
  global result
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
    # heat, car,place,time, ...
    result.append([trackCars[i], 0, cars[index][2][i]])
  result = sorted(result, key=lambda result: result[2])
  for i in range(len(result)):
    result[i][1] = i+1
  time.sleep(3)
  output()

def output():
  out = heat
  for i in range(len(trackCars)):
    if trackCars[i] == "0":
      out += ',0,0,0'
      continue
    for j in range(len(result)):
      if result[j][0] == trackCars[i]:
        out += ',%s,%d,%0.4f' % (trackCars[i], result[j][1], result[j][2])
  print(out)
  out += '\n'
  f = open(times+".tmp", 'w')
  f.write(out)
  f.close()
  f = open(timeslog, 'a')
  f.write(out)
  f.close
  os.rename(times+".tmp", times)

# ------------------------------

if __name__ == '__main__':

  doSimulate = False
  if len(sys.argv) > 1:
    doSimulate = True
    #print("simulate")

  while True:
    data = getNextHeat()
    if doSimulate:
      simulate()
    #print("heat:", heat, "trackCars:", trackCars)
    #for i in range(len(cars)):
      #print(" ", cars[i])
   
