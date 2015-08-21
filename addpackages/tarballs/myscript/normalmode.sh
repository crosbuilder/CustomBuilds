#!/bin/bash

cd `dirname $0`
# -fオプションがあるときだけhistoryに登録する
. ./script_root.sh
. ./addhistory.sh
if [ "$1" = "-f" ]; then
  msg=" -f option specified. Normal mode will be forced after updating the Chromium OS."
  addhistory /opt/myscript/normalmode.sh -q > /dev/null
else
  msg=" ( If you update Chromium OS, PC will return to Developer mode. Use -f option to set Normal mode after the update. )"
fi

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
  if [ -n "${debug}" ]; then
    sed -e 's/cros_debug //g' -i ${cfg} || exit 1
  fi
done

# disable syslinux boot prompt
noescape=`grep "NOESCAPE 1" syslinux.cfg`
if [ -z "${noescape}" ]; then
  sed -e '/^TIMEOUT/a NOESCAPE 1' -i syslinux.cfg || exit 1
fi

cd /tmp
sudo umount /tmp/mnt
rmdir /tmp/mnt

echo Return to Normal mode on next boot. 
if [ "$1" != "-q" ]; then
  echo ${msg}
fi

