#!/usr/bin/python3

import sys
import time

input = open('raw.out', 'r')
content = input.read()
#print(content)

lines = content.split('\n')

for l in lines:
  l = l.strip('\r\n@> ')
  if l == "":
    continue
  time.sleep(5)
  print(l)
  sys.stdout.flush()
