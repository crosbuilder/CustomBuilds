#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# disable vesa
mount -o remount,rw /
cd /usr/lib/xorg/modules/drivers/
if [ -f vesa_drv.so ]; then
  mv vesa_drv.so vesa_drv.so-
  echo disable vesa driver > /dev/tty1
fi


