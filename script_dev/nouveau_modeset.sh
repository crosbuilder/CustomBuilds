#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# mount EFI-SYSLINUX partition
root=`rootdev`
#root=/dev/sda3
syslinux=`echo ${root}|sed -e 's/\(3\|5\)/12/g'`
echo mount ${syslinux} | tee /dev/tty1 | logger -t myscript

mkdir /tmp/mnt
mount ${syslinux} /tmp/mnt
if [ 0 -ne $? ]; then
	exit 1
fi
cd /tmp/mnt

# rewrite kernel parameter
cfgdirlist=(/boot /tmp/mnt)
for cfgdir in ${cfgdirlist[@]}; do
  cd ${cfgdir}
  cfglist=(root.A.cfg root.B.cfg usb.A.cfg)
  for cfg in ${cfglist[@]}; do
    content=`cat syslinux/${cfg}`
    content_new=`echo "${content}" | sed -e "s/i915.modeset=[01]/i915.modeset=0 nouveau.modeset=1/g" -e "s/radeon.modeset=1/radeon.modeset=0/g"`
    if [ "${content}" != "${content_new}" ]; then
      echo modify ${cfg} | tee /dev/tty1 | logger -t myscript
      echo "${content_new}" > syslinux/${cfg}
    fi
  done
done

#umount EFI-SYSLINUX
cd ${script_root}
umount /tmp/mnt
echo umount ${syslinux} | tee /dev/tty1 | logger -t myscript

# disable vesa
${script_root}/disable_vesa.sh nohistory

