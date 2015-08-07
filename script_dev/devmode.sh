#!/bin/bash

# historyには登録しない

cd /tmp
if [ ! -e /tmp/mnt ]; then
  mkdir /tmp/mnt
fi

root=`rootdev`
syslinux=`echo ${root}|sed -e 's/\(3\|5\)/12/g'`
sudo mount ${syslinux} /tmp/mnt

if [ 0 -ne $? ]; then
  exit 1
fi
cd /tmp/mnt/syslinux

cfglist=(root.A.cfg root.B.cfg)
for cfg in ${cfglist[@]}; do
  debug=`grep append ${cfg} | grep cros_debug`
  if [ -z "${debug}" ]; then
    sed -e 's/append/append cros_debug/g' -i ${cfg}
  fi
done

# enable syslinux boot prompt
noescape=`grep "NOESCAPE 1" syslinux.cfg`
if [ -n "${noescape}" ]; then
  sed -e '/^NOESCAPE/d' -i syslinux.cfg

fi

cd /tmp
sudo umount /tmp/mnt
rmdir /tmp/mnt

echo Developer mode will be enabled on next boot. 

