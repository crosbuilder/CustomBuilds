#!/bin/bash

echo Apply Platform2 Patches
cd /home/chromium/myenv/patches/chromiumos-overlay

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

cd /home/chromium/trunk/src/third_party/chromiumos-overlay 
repo start my-chromiumos-overlay .
cd chromeos-base/tty
mv tty-0.0.1-r7.ebuild tty-0.0.1-r8.ebuild

if [ 0 -ne $? ]; then
  echo Failed to mv tty ebuild. Abort.
  exit 1
fi
