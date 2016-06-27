#!/bin/bash
myname=$0
cd ${myname%/*}

. ./revisionup_ebuild.sh

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit 1
fi

# portage-stableにディレクトリを作る

cd ~/trunk/src/third_party/portage-stable/net-wireless
if [ ! -d libertas-firmware ]; then
mkdir libertas-firmware
fi
cd libertas-firmware

# ebuildファイルをダウンロードする
wget --content-disposition http://mirror.linux.org.au/gentoo-portage/net-wireless/libertas-firmware/libertas-firmware-20101019.ebuild
if [ $? -ne 0 ]; then
  exit $?
fi

# ebuildのテストを実行する
cd ~/trunk/src/third_party/portage-stable/net-wireles/libertas-firmware
rm -f Manifest
ebuild-${BOARD} libertas-firmware-*.ebuild manifest
if [ $? -ne 0 ]; then
  exit $?
fi
ebuild-${BOARD} libertas-firmware-*.ebuild test
if [ $? -ne 0 ]; then
  exit $?
fi
emerge-${BOARD} net-wireless/libertas-firmware --pretend
if [ $? -ne 0 ]; then
  exit $?
fi

# 依存関係を追加
cd ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os
search=`grep 'net-wireless/libertas-firmware' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
        echo libertas-firmware is not included in base overlay. append to base overlay now.
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( net-wireless\/libertas-firmware )' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo libertas-firmware is already included in base overlay. skip.
fi

# ライセンスファイルをコピーする
cp ~/myenv/addpackages/ebuilds/net-wireless/libertas-firmware/license ~/trunk/src/third_party/portage-stable/licenses/libertas-fw

popd > /dev/null
