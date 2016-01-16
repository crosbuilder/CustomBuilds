#!/bin/bash

. /opt/myscript/common.sh

ROOTDRV=`rootdev -d`
#ROOTDRV=`rootdev | sed -e 's/[35]//'`
echo ROOTDRV=${ROOTDRV}
SYSLINUX=${ROOTDRV}12
echo SYSLINUX PARTITION=${SYSLINUX}

cd /tmp
if [ ! -d /tmp/mnt ]; then
  mkdir mnt
fi

sudo mount ${SYSLINUX} /tmp/mnt

A=`grep chromeos-hd.A /tmp/mnt/syslinux/default.cfg`
B=`grep chromeos-hd.B /tmp/mnt/syslinux/default.cfg`

if [ -n "${A}" ]; then
  OLDROOT=${ROOTDRV}5
  FS=`get_filesystem ${OLDROOT}`
  echo file system of ${OLDROOT} is ${FS}
  if [ -z "${FS}" ]; then
    echo File system of ${OLDROOT} is unknown. abort
    exit 1
  fi
  echo 'Change default boot config : chromeos-hd.A -> chromeos-hd.B'
  sudo sed -e 's/chromeos-hd.A/chromeos-hd.B/' -i /tmp/mnt/syslinux/default.cfg
elif [ -n "${B}" ]; then
  OLDROOT=${ROOTDRV}3
  FS=`get_filesystem ${OLDROOT}`
  echo file system of ${OLDROOT} is ${FS}
  if [ -z "${FS}" ]; then
    echo File system of "${OLDROOT}" is unknown. abort
    exit 1
  fi
  echo 'Change default boot config : chromeos-hd.B -> chromeos-hd.A'
  sudo sed -e 's/chromeos-hd.B/chromeos-hd.A/' -i /tmp/mnt/syslinux/default.cfg
else
  echo Boot media is removable. Abort.
  exit 1
fi

if [ $? -ne 0 ]; then
  echo failed to rewrite default.cfg
  sudo umount /tmp/mnt
  rmdir mnt
  exit 1
fi


sudo umount /tmp/mnt
rmdir mnt
echo Boot configuration changed. Please reboot.

