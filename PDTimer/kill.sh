#!/bin/sh


pids=`ps xa | grep Python3 | grep -v grep | awk '{print $1}'` 
echo $pids
kill $pids
