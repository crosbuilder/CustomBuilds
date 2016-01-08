#!/bin/bash

sudo mount -o remount,rw /
cd /etc/modprobe.d/

if [ ! -e /etc/modprobe.d/blacklist.conf ]; then
  echo blacklist.conf not found. create it.
  sudo sh -c "echo 'install rtl8180 /bin/false' >> blacklist.conf"
  sudo sh -c "echo 'install r8180 /bin/false' >> blacklist.conf"
  echo blacklist.conf created.
else
  g=`grep rtl8180 /etc/modprobe.d/blacklist.conf`
  if [ -z "$g" ]; then
    echo blacklist.conf not contains rtl8180.
    sudo sh -c "echo 'install rtl8180 /bin/false' >> blacklist.conf"
    echo add entry of rtl8180 to blacklist.conf
  else
    echo blacklist.conf found. skip.
  fi
  g=`grep r8180 /etc/modprobe.d/blacklist.conf`
  if [ -z "$g" ]; then
    echo blacklist.conf not contains r8180.
    sudo sh -c "echo 'install r8180 /bin/false' >> blacklist.conf"
    echo add entry of r8180 to blacklist.conf
  else
    echo blacklist.conf found. skip.
  fi
fi

# create preload-network-drivers
if [ ! -e /var/lib/preload-network-drivers ]; then
  echo preload-network-drivers not found. create it.
  echo r8187se > /var/lib/preload-network-drivers
  echo preload-network-drivers created.
else
  g=`grep r8187se /var/lib/preload-network-drivers`
  if [ -z "$g" ]; then
    echo preload-network-drivers not contains r8187se.
    sed -e '1i r8187se' -i /var/lib/preload-network-drivers
    echo add entry r8187se to preload-network-drivers
  else
    echo preload-network-drivers found. skip.
  fi
fi
sudo mount -o remount,ro /
