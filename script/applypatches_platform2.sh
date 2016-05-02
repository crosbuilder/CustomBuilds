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

