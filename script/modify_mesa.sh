#!/bin/bash

# vmware用パッチを当てる
echo patching ebuild to build vmware_dri.so
cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/mesa/mesa_ebuild.diff
if [ 0 -ne $? ]; then
  echo Failed to dry-run patch. Abort.
  exit 1
fi

patch -p1 < ~/myenv/patches/chromiumos-overlay/mesa/mesa_ebuild.diff
if [ 0 -ne $? ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi
