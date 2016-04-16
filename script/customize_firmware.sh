#!/bin/bash

cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 --dry-run < ~/myenv/patches/linux-firmware/linux-firmware-9999.ebuild.diff

read -p 'check dry-run patching result and if NG then press Ctrl-C ' status

patch -p1 < ~/myenv/patches/linux-firmware/linux-firmware-9999.ebuild.diff

cros_workon --board=x86-pentiumm start sys-kernel/linux-firmware

