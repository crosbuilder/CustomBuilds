#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# enable vesa
mount -o remount,rw /
cd /usr/lib/xorg/modules/drivers/
if [ -f vesa_drv.so- ]; then
  mv vesa_drv.so- vesa_drv.so
fi
cd /etc
echo X_ROOT >> ui_use_flags.txt
echo enable VESA. change X user to root | tee /dev/tty1 | logger -t myscript

