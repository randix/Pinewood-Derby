#!/usr/bin/env python3

import socket
import time


def broadcast():
  msg = bytes('Pinewood Derby url=https://castor.local:8484', 'utf-8')
  s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
  #s.bind(('0.0.0.0', 7777))
  while True:
   s.sendto(msg, ('255.255.255.255', 8484))
   print(msg)
   time.sleep(1)
   

def main():
  print("main")
  broadcast()

if __name__ == '__main__':
  main()
