#!/bin/bash

cd `dirname $0`
. ./script_root.sh
source addhistory.sh

# リブートせずに二度起動した時は何もしない

if [ -f ${script_local}/pre-shutdown.sh ]; then
  echo "installflash has been already executed. Skip."
  echo "Please reboot to start the installation. "
  exit 0
fi

# 32bit/64bit判定
arch="amd64"
is_x86=`uname -a | grep i686`
if [ -n "{is_x86}" ]; then
  arch="i386"
fi

# downloadflashはヒストリに記録しない（必ず手動で起動してインストールする）
#addhistory $0


if [ ! -d /mnt/stateful_partition/dev_image/myscript ]; then
  rm /mnt/stateful_partition/dev_image/myscript > /dev/null 2>&1
  mkdir /mnt/stateful_partition/dev_image/myscript
fi

# Packages.gzをダウンロードする
cd /mnt/stateful_partition/dev_image/myscript
mkdir chrome_work
cd chrome_work

echo download Packages.gz.
wget http://archive.canonical.com/ubuntu/dists/trusty/partner/binary-${arch}/Packages.gz
if [ $? -ne 0 ]; then
  echo Failed to download Packages.gz. Abort.
  cd ..
  rm -rf chrome_work
  exit 1
fi

gunzip -f Packages.gz

version=`grep -A10 -e "Package: adobe-flashplugin$" Packages | grep Version | sed -e 's/Version:.*://'`
echo version=${version}
package="adobe-flashplugin_${version}_${arch}.deb"

url="http://archive.canonical.com/ubuntu/pool/partner/a/adobe-flashplugin/${package}"

echo ${url}

echo Download Flash package...
wget ${url}

if [ $? -ne 0 ]; then
  echo Failed to download Flash Package. Abort.
  cd ..
  rm -rf chrome_work
  exit 1
fi

echo
echo Download is completed.
echo

echo Extract the package...
ar x ${package}
if [ 0 -ne $? ]; then
  echo "Failed to extract package(ar). Abort.."
  cd ..
  rm -rf chrome_work
  exit 1
fi
#tar xf data.tar.lzma --lzma
xz -dv data.tar.xz
if [ 0 -ne $? ]; then
  echo "Failed to extract package(xz). Abort.."
  cd ..
  rm -rf chrome_work
  exit 1
fi

tar xf data.tar
if [ 0 -ne $? ]; then
  echo Failed to unpack package. Abort..
  cd ..
  rm -rf chrome_work
  exit 1
fi
echo 
echo Extracted.
echo

echo Create symlink. 

# remount / writable
mount -o remount,rw /
if [ 0 -ne $? ]; then
  echo Failed to remount root partition. Abort..
  cd ..
  rm -rf chrome_work
  exit 1
fi

ln -s ${script_root}/installflash_ubuntu.sh ${script_local}/pre-shutdown.sh
if [ 0 -ne $? ]; then
  echo Failed to create symlink. Abort..
  cd ..
  rm -rf chrome_work
  exit 1
fi

mount -r -o remount /

echo 
echo Ready to Install. Please reboot to start the installation.

