#!/bin/bash
myname=$0
cd ${myname%/*}

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit 1
fi

# /tmp/portageに13.1.0のebuildを持ってくる

cros_portage_upgrade --board=${BOARD} --upgrade x11-drivers/xf86-video-vmware-13.1.0
if [ 0 -ne $? ]; then
	echo "[ERROR]cros_portage_upgrade failed. Abort."
	exit 1
fi

# overlayにコピー
cd ~/trunk/src/overlays/overlay-${BOARD}
if [ ! -d x11-drivers ]; then
  mkdir x11-drivers
  if [ 0 -ne $? ]; then
    echo "[ERROR] Failed to mkdir x11-drivers. Abort."
    exit 1
  fi
fi  

cd x11-drivers
cp -r ~/trunk/src/third_party/portage-stable/x11-drivers/xf86-video-vmware .
if [ 0 -ne $? ]; then
  echo "[ERROR]Failed to copy xf86-video-vmware pkg to overlay. Abort."
  exit 1
fi

# 既存のebuildとManifestを消す

cd xf86-video-vmware
rm *.ebuild
rm Manifest

# 13.1.0のebuildをコピーする

cp /tmp/portage/x11-drivers/xf86-video-vmware/xf86-video-vmware-13.1.0.ebuild .
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to portage-stable failed. Abort."
	exit 1
fi

# Manifestを再作成
ebuild-x86-pentiumm xf86-video-vmware-13.1.0.ebuild manifest
if [ 0 -ne $? ]; then
	echo "[ERROR]Failed to create Manifest. Abort."
	exit 1
fi

# テストコンパイル実行
#ebuild-x86-pentiumm xf86-video-vmware-13.1.0.ebuild compile
#if [ 0 -ne $? ]; then
#	echo "[ERROR]Failed to compile. Abort."
#	exit 1
#fi

