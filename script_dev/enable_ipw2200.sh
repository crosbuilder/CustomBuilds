#!/bin/bash
# search wireless device

source script_root.sh
source addhistory.sh

addhistory $0

for path in /sys/class/net/*
do
  if [ -e ${path}/wireless ]; then
    dev=${path##*/}
    echo wireless device is ${dev}
    break
  fi
done
if [ -z "${dev}" ]; then
  echo wireless device not found. Aborted.
  exit 1
fi

# remount root rw
mount -o remount,rw /

# add modprobe to pre-strat.conf

g=`grep "modprobe cfg80211" /etc/init/pre-startup.conf`
if [ -z "$g" ]; then
  echo pre-startup.conf is not modified.
  cp /etc/init/pre-startup.conf /etc/init/pre-startup.conf.old
  sed -e '/^ *static_node_tool/a modprobe cfg80211' -i /etc/init/pre-startup.conf
  echo pre-startup.conf has been modified.
else
  echo pre-startup.conf is already modified. skip.
fi

# remove modprobe from shill.conf

g=`grep '\#.*modprobe cfg80211.*$' /etc/init/shill.conf`
if [ -z "$g" ]; then
  echo shill.conf is not modified yet.
  cp /etc/init/shill.conf /etc/init/shill.conf.old
  sed -e 's/\(^ *modprobe cfg80211.*$\)/\#\1/' -e 's/\(^.*Failed to load cfg80211.*$\)/\#\1/' -i /etc/init/shill.conf
  echo shill.conf has been modified.
else
  echo shill.conf is already modified. skip.
fi

# modify params of wpa_supplicant
g=`grep Dwext /etc/init/wpasupplicant.conf`
if [ -z "$g" ]; then
  echo wpasupplicant.conf is not modified
  cp /etc/init/wpasupplicant.conf /etc/init/wpasupplicant.conf.old
  sed -e "s@/usr/sbin/wpa_supplicant\(.*$\)@/usr/sbin/wpa_supplicant -B -Dwext -i ${dev} \1 -c ${script_root}/wpa.conf@" -i /etc/init/wpasupplicant.conf
  echo wpasupplicant.conf has been modified.
else
  echo wpasupplicant.conf is already modified skip.
fi

# create preload-network-drivers
if [ ! -e /var/lib/preload-network-drivers ]; then
  preload-network-drivers not found. create it.
  echo ipw2200 > /var/lib/preload-network-drivers
  preload-network-drivers created.
else
  g=`grep ipw2200 /var/lib/preload-network-drivers`
  if [ -z "$g" ]; then
    echo preload-network-drivers not contains ipw2200.
    sed -e '1i ipw2200' -i /var/lib/preload-network-drivers
    echo add entry ipw2200 to preload-network-drivers
  else
    preload-network-drivers found. skip.
  fi
fi
