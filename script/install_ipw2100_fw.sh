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
	repo start my-portage-stable .
else
	echo branch already exists. skip.
fi

# ipw2100-firmwarenのパッケージをダウンロードする。
if [ ! -e ./sys-firmware/ipw2100-firmware ]; then
	echo ipw2100-firmware package does not fournd. download now.
	cros_portage_upgrade --board=${BOARD} --upgrade ipw2100-firmware || exit 1
	echo done.
else
	echo ipw2100-firmware package found. skip
fi

# 依存関係を追加
cd ${OVERLAY_DIR:=~/trunk/src/third_party/chromiumos-overlay}/virtual/target-chromium-os
search=`grep 'ipw2100-firmware' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
	echo ipw-firmware is not included in overlay. append to overlay now.
	sed -e '/RDEPEND="${CROS_COMMON_RDEPEND}/a \\tpenm? ( sys-firmware\/ipw2100-firmware )' -i target-chromium-os-1.ebuild || exit 1
	echo done
	revisionup_ebuild
else
	echo ipw2100-firmware is already included in overlay. skip.
fi


