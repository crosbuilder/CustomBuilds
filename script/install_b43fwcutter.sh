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

# b43-fwcutterのパッケージをダウンロードする。
if [ ! -e ./net-wireless/b43-fwcutter ]; then
	echo b43-fwcutter package does not fournd. download now.
	cros_portage_upgrade --board=${BOARD} --upgrade b43-fwcutter || exit 1
	echo done.
else
	echo b43-fwcutter package found. skip
fi

# 依存関係を追加
cd ${OVERLAY_DIR:=~/trunk/src/third_party/chromiumos-overlay}/virtual/target-chromium-os
search=`grep 'b43-fwcutter' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
	echo b43-fwcutter is not included in overlay. append to overlay now.
	sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( net-wireless\/b43-fwcutter )' -i target-chromium-os-1.ebuild || exit 1
	echo done
	revisionup_ebuild
else
	echo b43-fwcutter is already included in overlay. skip.
fi


