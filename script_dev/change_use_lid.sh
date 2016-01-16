#!/bin/bash

use_lid=/usr/share/power_manager/use_lid
sudo mount -o remount,rw /
status=`cat ${use_lid}`
if [ 1 -eq ${status} ]; then
  echo 'Current "use_lid_to_suspend" is enable.'
  sudo sh -c "echo 0 > ${use_lid}"
  echo '"use_lid_to_suspend" has been disabled'
else
  echo 'Current "use_lid_to_suspend" is disable.'
  sudo sh -c "echo 1 > ${use_lid}"
  echo '"use_lid_to_suspend" has been enabled.'

fi
sudo mount -o remount,ro /
echo Please reboot your machine.
