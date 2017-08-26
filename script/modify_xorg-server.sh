#!/bin/bash
. ./revisionup_ebuild.sh

cd ~/trunk/src/overlays/overlay-x86-pentiumm
mkdir x11-base
cd x11-base
cp -r ~/trunk/src/third_party/chromiumos-overlay/x11-base/xorg-server .
cd ~/trunk/src/overlays/overlay-x86-pentiumm

patch -p1 --dry-run < ~/myenv/patches/x11-base/xorg-server.patch
read -p 'check dry-run patching result and if NG then press Ctrl-C ' status

patch -p1 < ~/myenv/patches/x11-base/xorg-server.patch

cd x11-base/xorg-server
revisionup_ebuild
