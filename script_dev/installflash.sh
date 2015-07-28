#!/bin/bash

cd `dirname $0`
. ./script_root.sh
source addhistory.sh

# installflashはヒストリに記録しない（必ず手動で起動してインストールする）
#addhistory $0

cleanup() {
  cd /tmp 
  rm -rf chrome_work
# remount / read-only
mount -r -o remount / 
}

if [ -e /opt/google/chrome/PepperFlash/manifest.json ]; then

  old_version=`grep version /opt/google/chrome/PepperFlash/manifest.json | grep -o -E '[0-9\.]*'`
  echo Installed Flash Version: ${old_version}
  echo Start update...
else
  echo "Flash isn't installed."
  echo Start new installation...
fi

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
export PATH=${PATH}:/usr/local/bin
# download chrome stable version(x86)
echo Download Chrome package...
echo 
cd /tmp
mkdir chrome_work
cd chrome_work

if [ -e google-chrome-stable_current_i386.deb ]; then
  rm google-chrome-stable_current_i386.deb
fi
wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
if [ 0 -ne $? ]; then
  echo Download failed. Abort..
  exit 1
fi
echo
echo Download Completed.
echo
echo Extract package...
ar x google-chrome-stable_current_i386.deb
#tar xf data.tar.lzma --lzma
xz -dv data.tar.xz
tar xf data.tar
echo 
echo Extracted.
echo
echo get flash version...
cd opt/google/chrome/PepperFlash
flash_version=`grep version manifest.json | grep -o -E '[0-9\.]*'`
if [ -n version ]; then
  echo flash version is ${flash_version}
else
  echo failed to get flash version. Abort.
  cleanup
  exit 1
fi

echo copy plugins for rollback...
backupdir=/usr/local/myscript/flash_backup/${flash_version}
if [ ! -e /usr/local/myscript/flash_backup ]; then
  mkdir /usr/local/myscript/flash_backup
fi
mkdir ${backupdir}
cp -r ../PepperFlash ${backupdir}
#cp ../libffmpegsumo.so ${backupdir}
#cp ../libwidevinecdm.so ${backupdir}
#cp ../libwidevinecdmadapter.so ${backupdir}

echo install flash plugin

# remount / writable
mount -o remount,rw /

echo copy plugins
mkdir /opt/google/chrome/PepperFlash
cp libpepflashplayer.so /opt/google/chrome/PepperFlash -f
cp manifest.json /opt/google/chrome/PepperFlash -f
cd ..
#cp libffmpegsumo.so /opt/google/chrome
#cp libwidevinecdm.so /opt/google/chrome
#cp libwidevinecdmadapter.so /opt/google/chrome

echo add option to /etc/chrome_dev.conf

sed -e '/^--ppapi-flash-path=\/opt\/google\/chrome\/PepperFlash\/libpepflashplayer.so/d' -i /etc/chrome_dev.conf 
sed -e '/^--ppapi-flash-version.*/d' -i /etc/chrome_dev.conf

echo '--ppapi-flash-path=/opt/google/chrome/PepperFlash/libpepflashplayer.so' >> /etc/chrome_dev.conf
echo "--ppapi-flash-version=${flash_version}" >> /etc/chrome_dev.conf

cleanup
echo install Completed.

echo 
echo Please Restert your machine.
