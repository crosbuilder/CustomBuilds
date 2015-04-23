#!/bin/bash

source ./revisionup_ebuild.sh

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit
fi
# binutilsのバージョン：違うときは修正する
binutil_ver=`ar --version | grep -o -e '[0-9.]\+[0-9a-zA-Z]$'`

# arとlibbfdをtarにまとめる

mkdir ../addpackages/tarballs/ar
cp /build/${BOARD}/usr/i686-pc-linux-gnu/binutils-bin/${binutil_ver}/ar ../addpackages/tarballs/ar/
if [ 0 -ne $? ]; then
	echo "[ERROR]Copy ar failed. Abort."
	exit
fi
cp /build/${BOARD}/usr/lib/binutils/i686-pc-linux-gnu/${binutil_ver}/libbfd-${binutil_ver}.so ../addpackages/tarballs/ar/
if [ 0 -ne $? ]; then
	echo "[ERROR]Copy libbfd failed. Abort."
	exit
fi

pushd . > /dev/null

cd ../addpackages/tarballs/ar
tar zcvf ../ar.tar.gz .
if [ 0 -ne $? ]; then
	echo "[ERROR]Create tar failed. Abort."
	exit
fi


# 作成したtar.gzをキャッシュディレクトリに置く

cp ../ar.tar.gz /var/cache/chromeos-cache/distfiles/target/
if [ 0 -ne $? ]; then
	echo "[ERROR]copy tar to cache dir failed. Abort."
	exit
fi


# ebuildを所定の場所に置く
cd ../../ebuilds/app-misc
tar cvf - ar | (cd ~/trunk/src/third_party/portage-stable/app-misc; tar xf -)
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to portage-stable failed. Abort."
	exit
fi

# portageのパッケージ展開先をクリアしておく
portage_workdir=/build/${BOARD}/tmp/portage/app-misc/ar-1
if [ -e ${portage_workdir} ]; then
	rm -rf ${portage_workdir}
fi

# ebuildのテストを実行する
cd ~/trunk/src/third_party/portage-stable/app-misc/ar
rm -f Manifest
ebuild-${BOARD} ar-1.ebuild manifest
ebuild-${BOARD} ar-1.ebuild test
emerge-${BOARD} app-misc/ar --pretend

# 依存関係を追加
cd ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os-dev
search=`grep 'app-misc/ar' target-chromium-os-dev-1.ebuild`
if [ -z "${search}" ]; then
        echo ar is not included in dev overlay. append to dev overlay now.
        sed -e '/^RDEPEND="${RDEPEND}/a \\tapp-misc\/ar' -i target-chromium-os-dev-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo ar is already included in dev overlay. skip.
fi

popd > /dev/null
