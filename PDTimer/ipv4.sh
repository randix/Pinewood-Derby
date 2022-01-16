#!/bin/sh

echo
if [ `uname` = Linux ] ; then
  ip addr show wlan0 | grep 'inet ' | sed -e 's/\// /' | awk '{print $2}'
fi
if [ `uname` = Darwin ] ; then
  ifconfig en0 | grep 'inet ' | sed -e 's/\// /' | awk '{print $2}'
fi
echo
