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
if [ ! -d licenses/copyright-attribution/media-libs ]; then
  mkdir licenses/copyright-attribution/media-libs
  if [ 0 -ne $? ]; then
    echo Failed to mkdir license directory. Abort.
    exit 1
  fi
fi
cp /home/chromium/myenv/patches/chromiumos-overlay/mesa/license licenses/copyright-attribution/media-libs/mesa
if [ 0 -ne $? ]; then
  echo Failed to copy licence file of mesa. Abort.
  exit 1
fi

repo start my-chromiumos-overlay .
cd chromeos-base/tty
mv tty-0.0.1-r8.ebuild tty-0.0.1-r9.ebuild

if [ 0 -ne $? ]; then
  echo Failed to mv tty ebuild. Abort.
  exit 1
fi


