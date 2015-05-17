#!/bin/bash

source addhistory.sh

addhistory $0

set -x
pushd .

# remount rw
mount -o remount,rw /
if [ 0 -ne $? ]; then
  echo "[ERROR] Cannot remount / partition. Abort."
  exit
fi

# create mount point
cd /
mkdir mnt_fixsleep

# mount sda12
devpath=`fdisk -l | grep "EFI System" | cut -d " " -f 1`
mount ${devpath} /mnt_fixsleep
sed -e "s/append/append acpi_sleep=nonvs/" /mnt_fixsleep/syslinux/root.A.cfg > /mnt_fixsleep/syslinux/root.A.cfg.new
if [ 0 -eq $? ]; then
  status=`grep "acpi_sleep=nonvs" /mnt_fixsleep/syslinux/root.A.cfg.new | wc -l`
  if [ 2 -eq ${status} ]; then
    mv /mnt_fixsleep/syslinux/root.A.cfg /mnt_fixsleep/syslinux/root.A.cfg.old
    mv /mnt_fixsleep/syslinux/root.A.cfg.new /mnt_fixsleep/syslinux/root.A.cfg
  fi
fi

# unmount sda12
umount /mnt_fixsleep
if [ 0 -eq $? ]; then
  # delete mount point
  cd /
  rmdir mnt_fixsleep
fi

# remount read only
mount -r -o remount /

popd
