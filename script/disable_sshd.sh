#!/bin/bash
myname=$0
cd ${myname%/*}

. ./revisionup_ebuild.sh

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
        echo Please set BOARD. Abort.
        exit 1
fi

cd ~/trunk/src/overlays/overlay-${BOARD}/chromeos-base

cp -r /home/chromium/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-dev-root .
if [ $? -ne 0 ]; then
  echo Failed to copy chromeos-dev-root pkg. Abort.
  exit 1
fi

cd chromeos-dev-root

sed -e '/chromeos-base\/openssh-server-init/d' -i chromeos-dev-root-0.0.1.ebuild

revisionup_ebuild
