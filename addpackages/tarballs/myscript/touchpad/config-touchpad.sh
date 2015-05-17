#!/bin/bash

source ../script_root.sh
source ../addhistory.sh

addhistory /opt/myscript/touchpad/config-touchpad.sh

CONFIG_FILE="/etc/X11/xorg.conf.d/40-touchpad-cmt.conf"

# Check which type of touchpad is present.
if grep -qi synaptics /proc/bus/input/devices; then
  echo "Synaptics touchpad detected."
  TOUCHPAD="synaptics"
elif grep -qi alps /proc/bus/input/devices; then
  echo "ALPS touchpad detected."
  TOUCHPAD="alps"
elif grep -qi elantech /proc/bus/input/devices; then
  echo "Elantech touchpad detected."
  TOUCHPAD="elantech"
else
  echo "No known touchpad found, exiting."
  exit
fi

echo "Mounting the rootfs as read-write..."
mount -o remount, rw /

if [ ! -e "$CONFIG_FILE.bak" ]; then
  echo "Creating backup for $CONFIG_FILE..."
  cp $CONFIG_FILE $CONFIG_FILE.bak
fi

echo "Installing the configuration file for your touchpad..."
rm $CONFIG_FILE
cp ./$TOUCHPAD.xorg.conf $CONFIG_FILE

echo "Configuration finished. Please reboot to make the change effective."
