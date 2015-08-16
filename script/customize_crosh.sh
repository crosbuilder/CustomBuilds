#!/bin/bash

cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/crosh/crosh-9999.ebuild.diff

read -p 'check dry-run patching result and if NG then press Ctrl-C ' status

patch -p1 < ~/myenv/patches/chromiumos-overlay/crosh/crosh-9999.ebuild.diff

cd ~/trunk/src/platform2/
patch -p1 --dry-run < ~/myenv/patches/platform2/crosh.diff

read -p 'check dry-run patching result and if NG then press Ctrl-C ' status

patch -p1 < ~/myenv/patches/platform2/crosh.diff

#cp cp ~/myenv/patches/platform2/crosh-custom ./crosh/
cd /mnt/host/source/src/platform2/crosh
ln /mnt/host/source/chroot/home/chromium/myenv/patches/platform2/crosh-custom .

cd ~/trunk/src/scripts

cros_workon --board=x86-pentiumm start chromeos-base/crosh

