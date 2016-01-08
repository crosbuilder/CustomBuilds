#!/bin/bash

get_oldroot() {

  rootdrv=`rootdev | grep -o -e '/dev/[a-z]*'`
  partnum=`rootdev | grep -o -e '[35]'`
  if [ ${partnum} -eq 3 ]; then
    oldpartnum=5
  else
    oldpartnum=3
  fi
  echo ${rootdrv}${oldpartnum}
}

get_filesystem() {
  fs=`sudo blkid | grep $1 | grep -o -e 'TYPE="[^\"]*"'`
  echo ${fs}
}

if [ -d /opt/google/chrome/PepperFlash ]; then
  echo PepperFlash is already installed. Skip.
  exit 0
fi

oldroot=`get_oldroot`
oldroot_fs=`get_filesystem ${oldroot}`

if [ -z "${oldroot_fs}" ]; then
  echo "Couldn't find old Chromium OS installation. Skip."
  exit 0
fi

cd /tmp
if [ ! -d /tmp/mnt ]; then
  mkdir /tmp/mnt
fi

sudo mount ${oldroot} /tmp/mnt
if [ 0 -ne $? ]; then
  echo Failed to mount old root partition. Abort.
  exit 1
fi
echo Old root partition has been mounted.

status=0
if [ ! -d /tmp/mnt/opt/google/chrome/PepperFlash ]; then
  echo "PepperFlash wasn't found. Skip." 
else
  sudo mount -o remount,rw /
  cp -r /tmp/mnt/opt/google/chrome/PepperFlash /opt/google/chrome/
  if [ 0 -ne $? ]; then
    echo Failed to copy PepperFlash. Abort..
    status=1
  else
    grep 'ppapi-flash' /tmp/mnt/etc/chrome_dev.conf >> /etc/chrome_dev.conf
    echo PapperFlash has been copied.
  fi
  sudo mount -o remount,ro /
fi

sudo umount /tmp/mnt

echo Old root partition has been unmounted.
exit ${status}
