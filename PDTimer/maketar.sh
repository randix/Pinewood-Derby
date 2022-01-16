#!/bin/sh


cc -o find find.c

tar cvf PDTimer.tar \
          PDTimer.py parse.py timer.py \
          PIN.txt derby.txt \
          ipv4.sh t.sh tsim.sh kill.sh
