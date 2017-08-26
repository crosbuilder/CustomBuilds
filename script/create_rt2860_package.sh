#!/bin/bash

myname=$0
cd ${myname%/*}

source ./revisionup_ebuild.sh

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit 1
fi

# Debianのファームウェアパッケージをダウンロードして展開する
pushd . > /dev/null
mkdir ../addpackages/tarballs/ralink-rt2860-firmware
cd ../addpackages/tarballs/ralink-rt2860-firmware
wget http://ftp.jp.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-ralink_0.43_all.deb
if [ 0 -ne $? ]; then
        echo "[ERROR]Download firmware pkg failed. Abort."
        exit 1
fi
ar x firmware-ralink_0.43_all.deb
xz -cd data.tar.xz | tar xvf -

# rt2870.binは既にあるので消す。消さないとcollisionエラーになる
rm ./lib/firmware/rt2870.bin

# 展開したファームウェアをtarにまとめる

tar zcvf ../ralink-rt2860-firmware.tar.gz ./lib/firmware
if [ 0 -ne $? ]; then
        echo "[ERROR]Create tar failed. Abort."
        exit 1
fi


# 作成したtar.gzをキャッシュディレクトリに置く

cp ../ralink-rt2860-firmware.tar.gz /var/cache/chromeos-cache/distfiles/target/
if [ 0 -ne $? ]; then
        echo "[ERROR]copy tar to cache dir failed. Abort."
        exit 1
fi

# ebuildを所定の場所に置く
cd ~/myenv/addpackages/ebuilds/net-wireless
tar cvf - ralink-rt2860-firmware | (cd ~/trunk/src/third_party/portage-stable/net-wireless; tar xf -)
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to portage-stable failed. Abort."
	exit 1
fi

# portageのパッケージ展開先をクリアしておく
portage_workdir=/build/${BOARD}/tmp/portage/net-wireless/ralink-rt2860-firmware-1
if [ -e ${portage_workdir} ]; then
	sudo rm -rf ${portage_workdir}
fi

# ebuildのテストを実行する
cd ~/trunk/src/third_party/portage-stable/net-wireless/ralink-rt2860-firmware
rm -f Manifest
ebuild-${BOARD} ralink-rt2860-firmware-1.ebuild manifest
ebuild-${BOARD} ralink-rt2860-firmware-1.ebuild test
emerge-${BOARD} net-wireless/ralink-rt2860-firmware --pretend --verbose


# 依存関係を追加
cd ${OVERLAY_DIR:=~/trunk/src/third_party/chromiumos-overlay}/virtual/target-chromium-os
search=`grep 'ralink-rt2860-firmware' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
        echo ralink-rt2860-firmware is not included in base overlay. append to base overlay now.
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( net-wireless\/ralink-rt2860-firmware )' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo ralink-rt2860-firmware is already included in base overlay. skip.
fi
popd > /dev/null
