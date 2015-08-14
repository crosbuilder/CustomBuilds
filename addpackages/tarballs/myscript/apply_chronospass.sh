#!/bin/bash

if [ -f /mnt/stateful_partition/etc/devmode.passwd ]; then
  echo apply user defined password of chronos.
  pass=`cat /mnt/stateful_partition/etc/devmode.passwd`
  mount -o remount,rw /
  sed -e "/^chronos/d" -i /etc/shadow
  if [ 0 -ne $? ]; then
    echo Failed to apply chronos password.
  else
    echo "${pass}:::::::" >> /etc/shadow
    if [ 0 -ne $? ]; then
      echo Failed to apply chronos password.
    else
      echo done.
    fi
  fi

  mount -r -o remount /
fi
