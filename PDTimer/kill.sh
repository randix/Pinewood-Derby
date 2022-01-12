#!/bin/sh


html=`ps xa | grep PDTimer.py | grep -v grep | awk '{print $1}'` 
timr=`ps xa | grep timer.py   | grep -v grep | awk '{print $1}'` 
kill $html $timr
