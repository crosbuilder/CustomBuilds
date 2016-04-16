#!/bin/bash

source ./revisionup_ebuild.sh

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
	echo Please set BOARD. Abort.
	exit 1
fi

# ~/trunk/src/third_party/portage_stableにブランチが無ければ作る
cd ~/trunk/src/third_party/chromiumos-overlay
b=`repo branches | grep chromiumos-overlay`
if [ -z "$b" ]; then
        echo create branches on chromiumos-overlay
        repo start my-chromiumos-overlay . || exit 1
	echo done.
else
        echo branch already exists. skip.
fi

cros_portage_upgrade --board=${BOARD} --upgrade net-libs/nodejs || exit 1

# 依存関係を追加
cd ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os-dev
search=`grep 'nodejs' target-chromium-os-dev-1.ebuild`
if [ -z "${search}" ]; then
        echo nodejs is not included in dev overlay. append to dev overlay now.
        sed -e '/^RDEPEND="${RDEPEND}/a \\tpenm? ( net-libs\/nodejs )' -i target-chromium-os-dev-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo nodejs is already included in dev overlay. skip.
fi

search2=`grep -e 'IUSE=.* penm$' target-chromium-os-dev-1.ebuild`
if [ -z "${search2}" ]; then
        echo add penm to IUSE.
        sed -e 's/IUSE=\"/IUSE=\"penm /' -i target-chromium-os-dev-1.ebuild || exit 1
        echo done
else
        echo target-chromium-os-dev-1.ebuild already has penm in IUSE.
fi
