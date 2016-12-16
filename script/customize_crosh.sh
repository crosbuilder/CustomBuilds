#!/bin/bash

cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/crosh/crosh-9999.ebuild.diff
if [ $? -ne 0 ]; then
  echo Failed to dry-run patches. Abort.
  exit 1
fi

patch -p1 < ~/myenv/patches/chromiumos-overlay/crosh/crosh-9999.ebuild.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patches. Abort.
  exit 1
fi

cd ~/trunk/src/platform2/
patch -p1 --dry-run < ~/myenv/patches/platform2/crosh.diff
if [ $? -ne 0 ]; then
  echo Failed to dry-run patches. Abort.
  exit 1
fi

patch -p1 < ~/myenv/patches/platform2/crosh.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patches. Abort.
  exit 1
fi

#cp cp ~/myenv/patches/platform2/crosh-custom ./crosh/
cd /mnt/host/source/src/platform2/crosh
#ln /mnt/host/source/chroot/home/chromium/myenv/patches/platform2/crosh-custom .
cp -r /mnt/host/source/chroot/home/chromium/myenv/patches/platform2/custom.d .
if [ $? -ne 0 ]; then
  echo Failed to create hard link. Abort.
  exit 1
fi

cd ~/trunk/src/scripts

cros_workon --board=x86-pentiumm start chromeos-base/crosh
if [ $? -ne 0 ]; then
  echo Failed to cros_workon start. Abort.
  exit 1
fi

