#!/bin/bash
myname=$0
cd ${myname%/*}

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit 1
fi

# 既存のebuildとManifestを消す

cd ~/trunk/src/third_party/portage-stable/x11-drivers/xf86-video-vmware
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
ebuild-x86-pentiumm xf86-video-vmware-13.1.0.ebuild compile
if [ 0 -ne $? ]; then
	echo "[ERROR]Failed to compile. Abort."
	exit 1
fi

