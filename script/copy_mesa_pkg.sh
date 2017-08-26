#!/bin/bash

# vmware用パッチを当てる
echo copy mesa pkg to overlay directory
cd ~/trunk/src/overlays/overlay-x86-pentiumm
mkdir media-libs
if [ 0 -ne $? ]; then
  echo Failed to mkdir media-libs. Abort.
  exit 1
fi
cd media-libs
cp -r ~/trunk/src/third_party/chromiumos-overlay/media-libs/mesa .
if [ 0 -ne $? ]; then
  echo Failed to copy mesa pkg. Abort.
  exit 1
fi

echo patching ebuild to build vmware_dri.so
cd ~/trunk/src/overlays/overlay-x86-pentiumm
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
cd media-libs/mesa
sed -e '/^EAPI=4/a CROS_WORKON_ALWAYS_LIVE="1"' -i mesa-9999.ebuild
