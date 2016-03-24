#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# disable vesa
mount -o remount,rw /
# 32bitと64bitで場所が違う
is_x64=`uname -a | grep x86_64`
if [ -n "${is_x64}" ]; then
  cd /usr/lib64/xorg/modules/drivers/
else
  cd /usr/lib/xorg/modules/drivers/
fi

if [ -f vesa_drv.so ]; then
  mv vesa_drv.so vesa_drv.so-
  echo disable vesa driver | tee /dev/tty1 | logger -t myscript
fi


