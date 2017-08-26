#!/bin/bash
myname=$0
cd ${myname%/*}

source ./revisionup_ebuild.sh

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
	echo Please set BOARD. Abort.
	exit 1
fi

# ~/trunk/src/third_party/portage_stableにブランチが無ければ作る
cd ~/trunk/src/third_party/portage-stable
b=`repo branches | grep portage-stable`
if [ -z "$b" ]; then
        echo create branches on portage-stable
        repo start my-portage-stable . || exit 1
	echo done.
else
        echo branch already exists. skip.
fi

cros_portage_upgrade --board=${BOARD} --upgrade x11-drivers/xf86-input-vmmouse || exit 1

cd ~/trunk/src/overlays/overlay-${BOARD}

if [ ! -d x11-drivers ]; then
  mkdir x11-drivers
  if [ $? -ne 0 ]; then
    echo Failed to mkdir x11-drivers. Abort.
    exit 1
  fi
fi

cd x11-drivers
cp -r ~/trunk/src/third_party/portage-stable/x11-drivers/xf86-input-vmmouse .
if [ $? -ne 0 ]; then
  echo Failed to copy xf86-input-vmmouse pkg to overlay. Abort.
  exit 1
fi

cd ..

patch -p1 --dry-run < ~/myenv/patches/portage-stable/xf86-input-vmmouse-downgrade.patch
if [ $? -ne 0 ]; then
  echo Failed to dry-run patch. Abort.
  exit 1
fi

patch -p1 < ~/myenv/patches/portage-stable/xf86-input-vmmouse-downgrade.patch
if [ $? -ne 0 ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi

#cros_portage_upgrade --board=${BOARD} --upgrade x11-drivers/xf86-video-vmware || exit 1
#~/myenv/script/downgrade_xf86-video-vmware.sh || exit 1
