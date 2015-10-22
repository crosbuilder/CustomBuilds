#!/bin/bash

. ./revisionup_ebuild.sh

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit
fi

# 間違って有料コーデックありのもので上書きしてしまうミスを連発したためガードする
if [ -d ../addpackages/tarballs/libffmpeg-free ]; then
  echo Directory libffmpeg-free found. Abort.
  exit 0
fi

# libffmpeg.soをtarにまとめる
mkdir ../addpackages/tarballs/libffmpeg-free
cp /build/x86-pentiumm/usr/lib/libffmpeg.so ../addpackages/tarballs/libffmpeg-free/
if [ 0 -ne $? ]; then
	echo "[ERROR]Copy libffmpeg.so failed. Abort."
	exit
fi

pushd . > /dev/null

cd ../addpackages/tarballs/libffmpeg-free
tar zcvf ../libffmpeg-free.tar.gz .
if [ 0 -ne $? ]; then
	echo "[ERROR]Create tar failed. Abort."
	exit
fi


# 作成したtar.gzをキャッシュディレクトリに置く

cp ../libffmpeg-free.tar.gz /var/cache/chromeos-cache/distfiles/target/
if [ 0 -ne $? ]; then
	echo "[ERROR]copy tar to cache dir failed. Abort."
	exit
fi


# ebuildを所定の場所に置く
cd ../../ebuilds/chromeos-base
tar cvf - libffmpeg-free | (cd ~/trunk/src/third_party/chromiumos-overlay/chromeos-base; tar xf -)
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to  failed. Abort."
	exit
fi

# portageのパッケージ展開先をクリアしておく
portage_workdir=/build/${BOARD}/tmp/portage/chromeos-base/libffmpeg-free-1
if [ -e ${portage_workdir} ]; then
	rm -rf ${portage_workdir}
fi

# ebuildのテストを実行する
cd ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/libffmpeg-free
rm -f Manifest
ebuild-${BOARD} libffmpeg-free-1.ebuild manifest
ebuild-${BOARD} libffmpeg-free-1.ebuild test
emerge-${BOARD} chromeos-base/libffmpeg-free --pretend

# 依存関係を追加
cd ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os
search=`grep 'chromeos-base/libffmpeg-free' target-chromium-os-1.ebuild`
if [ -z "${search}" ]; then
        echo libffmpeg-free is not included in base overlay. append to base overlay now.
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tpenm? ( chromeos-base\/libffmpeg-free )' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo libffmpeg-free is already included in base overlay. skip.
fi

search2=`grep -e 'IUSE=.* penm$' target-chromium-os-1.ebuild`
if [ -z "${search2}" ]; then
	echo add penm to IUSE.
	sed -e 's/\(IUSE=.*$\)/\1 penm/' -i target-chromium-os-1.ebuild || exit 1
	echo done
else
	echo target-chromium-os-1.ebuild already has penm in IUSE.
fi

popd > /dev/null
