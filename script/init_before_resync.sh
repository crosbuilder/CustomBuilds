#!/bin/bash

# repo resync実行前にSDKへの変更をクリアする(R60以降)

cd ~/trunk/src/scripts/
git reset --hard
git clean -fdx

cd ~/trunk/src/third_party/portage-stable
git reset --hard
git clean -fdx

cd ~/trunk/src/third_party/kernel/v4.4/ 
git reset --hard
git clean -fdx

cd ~/trunk/src/third_party/chromiumos-overlay/
git reset --hard
git clean -fdx

# patchの再適用ができるようにする
cd ~/myenv/patches/kernel-4_4
make clean

cd ../bootloader
make clean

cd ../chromiumos-overlay/
make clean

if [ ! -d ~/myenv/overlays ]; then
  mkdir ~/myenv/overlays
fi

STRDATE=`date +%Y%m%d%H%M%S`
if [ -d ~/trunk/src/overlays/overlay-x86-xorg ]; then
  if [ -d ~/myenv/overlays/overlay-x86-xorg ]; then
    rm -rf ~/myenv/overlays/overlay-x86-xorg
  fi
  cp -r ~/trunk/src/overlays/overlay-x86-xorg ~/myenv/overlays/overlay-x86-xorg-${STRDATE}
  rm -rf ~/trunk/src/overlays/overlay-x86-xorg
fi

if [ -d ~/trunk/src/overlays/overlay-x86-pentiumm ]; then
  if [ -d ~/myenv/overlays/overlay-x86-pentiumm ]; then
    rm -rf ~/myenv/overlays/overlay-x86-pentiumm
  fi
  cp -r ~/trunk/src/overlays/overlay-x86-pentiumm ~/myenv/overlays/overlay-x86-pentiumm-${STRDATE}
  rm -rf ~/trunk/src/overlays/overlay-x86-pentiumm 
fi

