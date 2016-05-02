#!/bin/bash
myname=$0
cd ${myname%/*}

source ./revisionup_ebuild.sh

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
	echo Please set BOARD. Abort.
	exit 1
fi

# ~/trunk/src/third_party/chromiumos-overlayにブランチが無ければ作る
cd ~/trunk/src/third_party/chromiumos-overlay
b=`repo branches | grep chromiumos-overlay`
if [ -z "$b" ]; then
        echo create branches on chromiumos-overlay
        repo start my-chromiumos-overlay . || exit 1
	echo done.
else
        echo branch already exists. skip.
fi

# ~/trunk/src/third_party/chromiumos-overlay/profiles/targets/chromeos/package.providedからzipのエントリを消す
cd profiles/targets/chromeos
sed -e 's@^app-arch/zip@#app-arch/zip@' -i package.provided

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

cros_portage_upgrade --board=${BOARD} --upgrade app-arch/zip || exit 1
cros_portage_upgrade --board=${BOARD} --upgrade app-arch/unzip || exit 1

# 依存関係を追加
cd ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os
search=`grep 'app-arch/zip' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
        echo zip is not included in base overlay. append to base overlay now.
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( app-arch\/zip )' -i target-chromium-os-1.ebuild || exit 1
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( app-arch\/unzip )' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo zip is already included in base overlay. skip.
fi

