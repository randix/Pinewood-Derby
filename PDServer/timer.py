#!/usr/bin/env python3

import os
import time
import sys

nextheat = "nextheat.csv"
heat = 0
trackCars = []
cars = []

simulate = False

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
          cars.append([data[i]])
      os.remove(nextheat)
      return data
    except:
      #print("except")
      continue

def simulate():
  return

# ------------------------------

if __name__ == '__main__':

  simulate = False
  if len(sys.argv) > 1:
    simulate = True
    print("simulate")

  while True:
    data = getNextHeat()
    print("heat:", heat, "trackCars:", trackCars)
    print("cars:", cars)
   
    
