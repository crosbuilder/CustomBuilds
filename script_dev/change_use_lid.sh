#!/bin/bash

use_lid_base=/usr/share/power_manager/use_lid
use_lid=/var/lib/power_manager/use_lid
#sudo mount -o remount,rw /
if [ ! -f ${use_lid} ]; then
  status=`cat ${use_lid_base}`
else
  status=`cat ${use_lid}`
fi
if [ 1 -eq ${status} ]; then
  echo 'Current "lid_closed_action" is "suspend".'
  sudo sh -c "echo 0 > ${use_lid}"
  sudo set_power_policy --lid_closed_action=do_nothing
  echo '"lid_closed_action" has been changed to "do_nothing".'
else
  echo 'Current "lid_closed_action" is "do_nothing".'
  sudo sh -c "echo 1 > ${use_lid}"
  sudo set_power_policy --lid_closed_action=suspend
  echo '"lid_closed_action" has been changed to "suspend".'
fi
echo 'Please reboot your machine.'
