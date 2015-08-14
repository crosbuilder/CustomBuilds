#!/bin/bash

cd `dirname $0`
. ./script_root.sh
source addhistory.sh

# installflashはヒストリに記録しない（必ず手動で起動してインストールする）
#addhistory $0

cleanup() {
  cd /tmp 
  rm -rf chrome_work
  unlink ${script_root}/pre-shutdown.sh

  # remount / read-only
  mount -r -o remount / 
}

# enable echo on /dev/tty1
(stty -F /dev/tty1 echo echonl icanon iexten isig; sleep 5) > /dev/tty1

if [ -e /opt/google/chrome/PepperFlash/manifest.json ]; then

  old_version=`grep version /opt/google/chrome/PepperFlash/manifest.json | grep -o -E '[0-9\.]*'`
  echo -e "Installed Flash Version: ${old_version}\n" | tee /dev/tty1 | logger -t myscript
  echo -e "Start update...\n" | tee /dev/tty1 | logger -t myscript
else
  echo -e "Flash isn't installed.\n" | tee /dev/tty1 | logger -t myscript
  echo -e "Start new installation...\n" | tee /dev/tty1 | logger -t myscript
fi

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
export PATH=${PATH}:/usr/local/bin
# download chrome stable version(x86)

# check workdir is exist
if [ ! -d /tmp/chrome_work ]; then
  echo -e "/tmp/chrome_work not found.\n" | tee /dev/tty1 | logger -t myscript
  echo -e "Please run downloadflash.sh before.\n" | tee /dev/tty1 | logger -t myscript
  cleanup
  exit 1
fi

cd /tmp/chrome_work

echo -e "get flash version...\n" | tee /dev/tty1 | logger -t myscript
cd opt/google/chrome/PepperFlash
flash_version=`grep version manifest.json | grep -o -E '[0-9\.]*'`
if [ -n version ]; then
  echo -e "flash version is ${flash_version}\n" | tee /dev/tty1 | logger -t myscript
else
  echo -e "failed to get flash version. Abort.\n" | tee /dev/tty1 | logger -t myscript
  cleanup
  exit 1
fi

echo -e "copy plugins for rollback...\n" | tee /dev/tty1 | logger -t myscript
backupdir=${script_local}/flash_backup/${flash_version}
if [ ! -e ${script_local}/flash_backup ]; then
  mkdir ${script_local}/flash_backup
fi
mkdir ${backupdir}
cp -r ../PepperFlash ${backupdir}
#cp ../libffmpegsumo.so ${backupdir}
#cp ../libwidevinecdm.so ${backupdir}
#cp ../libwidevinecdmadapter.so ${backupdir}

echo -e "install flash plugin\n" | tee /dev/tty1 | logger -t myscript

# remount / writable
mount -o remount,rw /

echo -e "copy plugins\n" | tee /dev/tty1 | logger -t myscript
mkdir /opt/google/chrome/PepperFlash
cp libpepflashplayer.so /opt/google/chrome/PepperFlash -f
cp manifest.json /opt/google/chrome/PepperFlash -f
cd ..
#cp libffmpegsumo.so /opt/google/chrome
#cp libwidevinecdm.so /opt/google/chrome
#cp libwidevinecdmadapter.so /opt/google/chrome

echo -e "add option to /etc/chrome_dev.conf\n" | tee /dev/tty1 | logger -t myscript

sed -e '/^--ppapi-flash-path=\/opt\/google\/chrome\/PepperFlash\/libpepflashplayer.so/d' -i /etc/chrome_dev.conf 
sed -e '/^--ppapi-flash-version.*/d' -i /etc/chrome_dev.conf

echo '--ppapi-flash-path=/opt/google/chrome/PepperFlash/libpepflashplayer.so' >> /etc/chrome_dev.conf
echo "--ppapi-flash-version=${flash_version}" >> /etc/chrome_dev.conf

echo -e "The installation is Completed.\n" | tee /dev/tty1 | logger -t myscript
cleanup

