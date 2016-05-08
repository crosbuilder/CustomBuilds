#!/bin/bash

cd `dirname $0`
. ./script_root.sh
source addhistory.sh

# installflashはヒストリに記録しない（必ず手動で起動してインストールする）
#addhistory $0


# enable echo on /dev/tty1
(stty -F /dev/tty1 echo echonl icanon iexten isig; sleep 5) > /dev/tty1

# check workdir is exist
if [ ! -d ${script_local}/chrome_work ]; then
  echo -e "${script_local}/chrome_work not found.\n" | tee /dev/tty1 | logger -t myscript
  echo -e "Please run downloadflash.sh before.\n" | tee /dev/tty1 | logger -t myscript
  cleanup
  exit 1
fi

cd ${script_local}/chrome_work

echo -e "install flash plugin\n" | tee /dev/tty1 | logger -t myscript

# remount / writable
mount -o remount,rw /

echo -e "Copy Flash plugins\n" | tee /dev/tty1 | logger -t myscript
#mkdir /opt/google/chrome/PepperFlash
cp -r usr/lib/adobe-flashplugin /usr/lib/
cd ..

echo -e "add option to /etc/chrome_dev.conf\n" | tee /dev/tty1 | logger -t myscript

sed -e '/^--ppapi-flash-path=.*/d' -i /etc/chrome_dev.conf 
sed -e '/^--ppapi-flash-version.*/d' -i /etc/chrome_dev.conf

echo '--ppapi-flash-path=/usr/lib/adobe-flashplugin/libpepflashplayer.so' >> /etc/chrome_dev.conf
echo "--ppapi-flash-version=" >> /etc/chrome_dev.conf

echo -e "The installation is Completed.\n" | tee /dev/tty1 | logger -t myscript
  echo script_local=${script_local} | tee /dev/tty1 | logger -t myscript

  echo cleanup... | tee /dev/tty1 | logger -t myscript
  cd ${script_local} 
  rm -rf chrome_work
#  unlink ${script_local}/pre-shutdown.sh 2>&1 | tee /dev/tty1 | logger -t myscript
  unlink ${script_local}/pre-shutdown.sh 2>&1 | tee /dev/tty1 | logger -t myscript

  # remount / read-only
  mount -r -o remount / 
