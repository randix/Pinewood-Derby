#!/usr/bin/python3

import sys


f = open('raw.csv', 'r')

scores = {}
#sums = {}

def add(car, time):
  c = int(car)
  t = float(time)
  if t == 0.0:
    t = 9.0
  if c in scores:
    scores[c].append(t)
  else:
    scores[c] = [t]


while True:
  l = f.readline()
  if l == '':
    break
  p = l.split(',')
  #print(len(p), p)
  add(p[1], p[3])
  add(p[4], p[6])
  add(p[7], p[9])
  add(p[10], p[12])
  
keys = sorted(scores.keys())

# sort the scores
for k in keys:
  scores[k] = sorted(scores[k])

s = open('scores.csv', 'w')
# output the dictionary (sorted)
for k in keys:
  #sum = 0
  #for i in range(len(scores[k])):
  #  sum += scores[k][i]
  #  if i == 0:
  #    sums[k] = [sum]
  #  else:
  #    sums[k].append(sum)
  #print(k, scores[k], sums[k])
  print(k, scores[k])
  s.write('%d,' % (k))
  for i in range(4):
   if len(scores[k]) > i:
     s.write('%6.4f,' % scores[k][i])
   else:
     s.write('%6.4f,' % 9)
   #if len(sums[k]) > i:
   #  s.write('%6.4f,' % sums[k][i])
   #else:
   #  s.write('%6.4f,' % 9)
  s.write('\n')

s.close()

