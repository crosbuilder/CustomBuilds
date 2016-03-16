#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# enable vesa
mount -o remount,rw /

# 32bitと64bitで場所が違う
is_x64=`uname -a | grep x86_64`
if [ -n "{is_x64}" ]; then
  cd /usr/lib64/xorg/modules/drivers/
else
  cd /usr/lib/xorg/modules/drivers/
fi

if [ -f vesa_drv.so- ]; then
  mv vesa_drv.so- vesa_drv.so
fi
cd /etc
echo X_ROOT >> ui_use_flags.txt
echo enable VESA. change X user to root | tee /dev/tty1 | logger -t myscript

