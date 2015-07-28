#!/bin/bash

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

# p7zipがない、またはバージョンが9.13ならパッケージをダウンロードする
upgrade="false"
if [ ! -e ./app-arch/p7zip ]; then
	echo app-arch/p7zip package not found. download now.
	upgrade="true"
elif [ -e ./app-arch/p7zip/p7zip-9.13.ebuild ]; then
	echo app-arch/p7zip package is old. download new package now.
	upgrade="true"
fi

if [ ${upgrade} = "true" ]; then
	cros_portage_upgrade --board=${BOARD} --upgrade app-arch/p7zip || exit 1
else
	echo app-arch/p7zip package found. skip.
fi

# 9.20.1.r4ではそのままではビルドできなかったのでebuildにパッチを当てる
patch -p1 --dry-run < ~/myenv/patches/p7zip/p7zip-9.20.1-r4.ebuild.diff
read -p 'above is results of dry-running patch. apply patch?[N/y]' status
if [ ${status} = 'y' ]; then
	patch -p1 < ~/myenv/patches/p7zip/p7zip-9.20.1-r4.ebuild.diff || exit 1
	echo patch applied.
else
	exit 1
fi


# 依存関係を追加
cd ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os
search=`grep 'p7zip' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
        echo p7zip is not included in base overlay. append to base overlay now.
        sed -e '/^RDEPEND="${RDEPEND}/a \\tapp-arch\/p7zip' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo p7zip is already included in base overlay. skip.
fi

