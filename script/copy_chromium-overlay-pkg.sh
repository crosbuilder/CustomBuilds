#!/bin/bash

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
        echo Please set BOARD. Abort.
        exit 1
fi

# パッケージをオーバレイディレクトリにコピー
cd ~/trunk/src/overlays/overlay-${BOARD}

if [ ! -d sys-libs ]; then
  mkdir sys-libs
  if [ 0 -ne $? ]; then
    echo Failed to mkdir sys-libs. Abort.
    exit 1
  fi
fi
cp -r ~/trunk/src/third_party/chromiumos-overlay/sys-libs/gcc-libs ./sys-libs/
if [ 0 -ne $? ]; then
  echo Failed to copy gcc-libs pkg. Abort.
  exit 1
fi

# R60でcros_debugが指定されてないとttyを無効にするコードが本家でも入ったようなのでスキップ
#if [ ! -d chromeos-base ]; then
#  mkdir chromeos-base
#  if [ 0 -ne $? ]; then
#    echo Failed to mkdir chromeos-base Abort.
#    exit 1
#  fi
#fi
#cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/tty ./chromeos-base/
#if [ 0 -ne $? ]; then
#  echo Failed to copy tty pkg. Abort.
#  exit 1
#fi

if [ ! -d sys-kernel ]; then
  mkdir sys-kernel
  if [ 0 -ne $? ]; then
    echo Failed to mkdir sys-kernel Abort.
    exit 1
  fi
fi
cp -r ~/trunk/src/third_party/chromiumos-overlay/sys-kernel/linux-firmware ./sys-kernel/
if [ 0 -ne $? ]; then
  echo Failed to copy linux-firmware pkg. Abort.
  exit 1
fi


echo Apply Patches to chromiumos-overlay pkg.
cd /home/chromium/myenv/patches/chromiumos-overlay

make TARGET_DIR=~/trunk/src/overlays/overlay-${BOARD} dryrun
if [ 0 -ne $? ]; then
  echo Failed to dryrun. Abort.
  exit 1
fi
make TARGET_DIR=~/trunk/src/overlays/overlay-${BOARD} apply
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
#cd ~/trunk/src/overlays/overlay-${BOARD}/chromeos-base/tty
#mv tty-0.0.1-r8.ebuild tty-0.0.1-r9.ebuild
#
#if [ 0 -ne $? ]; then
#  echo Failed to mv tty ebuild. Abort.
#  exit 1
#fi


