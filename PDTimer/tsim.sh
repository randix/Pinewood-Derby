#!/bin/sh

set -x

nohup python3 -u ./timer.py sim  > timer.log &
nohup python3 -u ./PDTimer.py   2> server.log &
