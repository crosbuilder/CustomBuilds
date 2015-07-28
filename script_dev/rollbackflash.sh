#!/bin/bash

# ロールバックはヒストリに記録しない

if [ -z $1 ]; then
  echo please set target version
  exit 1
fi

if [ ! -e /usr/local/myscript/flash_backup/$1 ]; then
  echo Sorry, backup plugin Ver.$1 not found. Aborted.
  exit 1
fi

if [ -e /opt/google/chrome/PepperFlash/manifest.json ]; then

  local old_version=`grep version /opt/google/chrome/PepperFlash/manifest.json | grep -o -E '[0-9\.]*'`
  echo Installed Flash Version: ${old_version}
  echo Start rollback to Flash Ver.$1 ...
else
  echo "Flash isn't installed."
  echo Rollback aborted.
  exit 1 
fi

echo get flash version...
cd /usr/local/myscript/flash_backup/$1/PepperFlash
flash_version=`grep version manifest.json | grep -o -E '[0-9\.]*'`
if [ -n version ]; then
  echo flash version is ${flash_version}
else
  echo failed to get flash version. Abort.
  cleanup
  exit 1
fi

echo install flash plugin

# remount / writable
mount -o remount,rw /

echo copy plugins
mkdir /opt/google/chrome/PepperFlash
cp libpepflashplayer.so /opt/google/chrome/PepperFlash -f
cp manifest.json /opt/google/chrome/PepperFlash -f
cd ..
#cp libffmpegsumo.so /opt/google/chrome

echo add option to /etc/chrome_dev.conf

sed -e '/^--ppapi-flash-path=\/opt\/google\/chrome\/PepperFlash\/libpepflashplayer.so/d' -i /etc/chrome_dev.conf 
sed -e '/^--ppapi-flash-version.*/d' -i /etc/chrome_dev.conf

echo '--ppapi-flash-path=/opt/google/chrome/PepperFlash/libpepflashplayer.so' >> /etc/chrome_dev.conf
echo "--ppapi-flash-version=${flash_version}" >> /etc/chrome_dev.conf

echo rollback Completed.

echo 
echo Please Restert your machine.
