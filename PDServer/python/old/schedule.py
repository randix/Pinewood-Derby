#!/usr/bin/python3

"""
This simply randomizes a column of numbers
from a file and writes to a new file.
"""

ifile = 'cars.txt'
ofile = 'cars-random.txt'

import random


f = open(ifile, 'r')

cars = []
while True:
  l = f.readline().strip()
  if l == '':
    break
  cars.append(l)

random.shuffle(cars)

f = open(ofile, 'w')
for c in cars:
  print(c)
  f.write('%s\n' % c)
f.close()

