#!/bin/bash
myname=$0
cd ${myname%/*}

. ./revisionup_ebuild.sh

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit 1
fi

# BOARDの設定内容を表示して確認を取る
echo Start to create ar package for BOARD : ${BOARD}
echo 
read -p 'continue?' status

tarfile=ar_${BOARD}.tar.gz

# binutilsのバージョン：違うときは修正する
libbfd_ver=`ar --version | grep -o -e '[0-9.]\+[0-9a-zA-Z]$'`
binutil_ver=`ar --version | grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+' |head -n 1`


# arとlibbfdをtarにまとめる

mkdir ../addpackages/tarballs/ar-${BOARD}
arch="i686-pc-linux-gnu"
lib="lib"
tokens=( `echo ${BOARD}|tr -s '-' ' '` )
if [ "${tokens[0]}" = "amd64" ]; then
  arch="x86_64-cros-linux-gnu"
  lib="lib64"
fi

cp /build/${BOARD}/usr/${arch}/binutils-bin/${binutil_ver}/ar ../addpackages/tarballs/ar-${BOARD}/
if [ 0 -ne $? ]; then
	echo "[ERROR]Copy ar failed. Abort."
	exit 1
fi
cp /build/${BOARD}/usr/${lib}/binutils/${arch}/${binutil_ver}/libbfd-${libbfd_ver}.so ../addpackages/tarballs/ar-${BOARD}/
if [ 0 -ne $? ]; then
	echo "[ERROR]Copy libbfd failed. Abort."
	exit 1
fi

pushd . > /dev/null

cd ../addpackages/tarballs/ar-${BOARD}
tar zcvf ../${tarfile} .
if [ 0 -ne $? ]; then
	echo "[ERROR]Create tar failed. Abort."
	exit 1
fi


# 作成したtar.gzをキャッシュディレクトリに置く

cp ../${tarfile} /var/cache/chromeos-cache/distfiles/target/
if [ 0 -ne $? ]; then
	echo "[ERROR]copy tar to cache dir failed. Abort."
	exit 1
fi


# ebuildを所定の場所に置く
cd ../../ebuilds/app-misc
sed -e "s/libbfd-.*.so/libbfd-${libbfd_ver}.so/" -i ar/ar-1.ebuild
tar cvf - ar | (cd ~/trunk/src/third_party/portage-stable/app-misc; tar xf -)
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to portage-stable failed. Abort."
	exit 1
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
cd ${OVERLAY_DIR:=~/trunk/src/third_party/chromiumos-overlay}/virtual/target-chromium-os
search=`grep 'app-misc/ar' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
        echo ar is not included in base overlay. append to base overlay now.
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( app-misc\/ar )' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo ar is already included in base overlay. skip.
fi

popd > /dev/null
