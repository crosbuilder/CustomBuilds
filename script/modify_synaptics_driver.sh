#!/bin/bash

# ~/trunk/src/third_party/portage-stableにブランチが無ければ作る
cd ~/trunk/src/third_party/portage-stable
b=`repo branches | grep portage-stable`
if [ -z "$b" ]; then
	echo create branches on portage-stable
	repo start my-portage-stable .
else
	echo branch already exists. skip.
fi

patch -p1 < ~/myenv/patches/portage-stable/synaptic-compile-error.diff
if [ $? -ne 0 ]; then
  echo apply patch failed.
  exit 1
fi
git add x11-drivers/xf86-input-synaptics/xf86-input-synaptics-1.6.2.ebuild
git add x11-drivers/xf86-input-synaptics/files/
git commit -m "synapticsドライバコンパイルエラー修正"

