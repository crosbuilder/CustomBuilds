#!/bin/bash

cd ~/trunk/src/third_party/chromiumos-overlay/media-libs/mesa
ebuild=`ls -1 *.ebuild | grep -v 9999 | grep -v r`
mesa_version=${ebuild%.*}

ebuild-x86-pentiumm ${ebuild} clean
ebuild-x86-pentiumm ${ebuild} unpack

cd ~/trunk/src/third_party

if [ -d mesa-old ]; then
  rm -rf mesa-old
fi

if [ -d mesa ]; then
  mv mesa mesa-old
fi

if [ ! -d /build/x86-pentiumm/tmp/portage/media-libs/${mesa_version}/work ]; then
  echo failed to cd ${mesa_version}/work. Abort
  exit 1
fi
cd /build/x86-pentiumm/tmp/portage/media-libs/${mesa_version}/work
tar cfh - ./mesa | (cd ~/trunk/src/third_party/; tar xvf -)
if [ $? -ne 0 ]; then
  echo Failed to copy sources of mesa. Abort.
  exit 1
fi
  
