#!/bin/bash
. ./revisionup_ebuild.sh

cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 --dry-run < ~/myenv/patches/x11-base/xorg-server.patch
read -p 'check dry-run patching result and if NG then press Ctrl-C ' status

patch -p1 < ~/myenv/patches/x11-base/xorg-server.patch

cd x11-base/xorg-server
revisionup_ebuild
