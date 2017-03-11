#!/bin/bash

echo Apply Platform2 Patches
cd /home/chromium/myenv/patches/platform2

make dryrun
if [ 0 -ne $? ]; then
  echo Failed to dryrun. Abort.
  exit 1
fi
make apply
if [ 0 -ne $? ]; then
  echo Failed to patch. Abort.
  exit 1
fi

# 以下のスクリプトはAtom N280+945GSEの環境でハングアップや電源断を起こす。品質調査用であり、動作に必須ではないので消す。
if [ -f ~/trunk/src/platform2/init/send-boot-mode.conf ]; then
  rm -f ~/trunk/src/platform2/init/send-boot-mode.conf
  if [ 0 -ne $? ]; then
    echo Failed to delete send-boot-mode.conf. Abort.
    exit 1
  fi
fi

cros_workon --board=x86-pentiumm start chromeos-base/chromeos-login
if [ 0 -ne $? ]; then
  echo Failed to cros_workon start chromeos-login Abort.
  exit 1
fi
cros_workon --board=x86-pentiumm start chromeos-base/chromeos-installer
if [ 0 -ne $? ]; then
  echo Failed to cros_workon start chromeos-installer Abort.
  exit 1
fi
cros_workon --board=x86-pentiumm start chromeos-base/chromeos-init
if [ 0 -ne $? ]; then
  echo Failed to cros_workon start chromeos-init Abort.
  exit 1
fi
cros_workon_make --board=x86-pentiumm chromeos-base/chromeos-installer --install
if [ 0 -ne $? ]; then
  echo Failed to cros_workon_maket chromeos-installer Abort.
  exit 1
fi

