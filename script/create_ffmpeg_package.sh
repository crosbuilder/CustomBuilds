#!/bin/bash
myname=$0
cd ${myname%/*}

. ./revisionup_ebuild.sh

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit 1
fi

# BOARDの設定内容を表示して確認を取る
echo Start to create libffmpeg package for BOARD : ${BOARD}
echo 
read -p 'continue?' status

tarfile=libffmpeg-free_${BOARD}.tar.gz

if [ -d ../addpackages/tarballs/libffmpeg-free-${BOARD}-old ]; then
  rm -rf ../addpackages/tarballs/libffmpeg-free-${BOARD}-old
  if [ $? -ne 0 ]; then
    echo Failed to remove old dir. Abort.
    exit 1
  fi
fi

if [ -d ../addpackages/tarballs/libffmpeg-free-${BOARD} ]; then
  mv ../addpackages/tarballs/libffmpeg-free-${BOARD} ../addpackages/tarballs/libffmpeg-free-${BOARD}-old
  if [ $? -ne 0 ]; then
    echo Failed to move old dir. Abort.
    exit 1
  fi
fi

# libffmpeg.soをtarにまとめる
mkdir ../addpackages/tarballs/libffmpeg-free-${BOARD}
cp /build/${BOARD}/usr/lib/libffmpeg.so ../addpackages/tarballs/libffmpeg-free-${BOARD}/
if [ 0 -ne $? ]; then
	echo "[ERROR]Copy libffmpeg.so failed. Abort."
	exit 1
fi

pushd . > /dev/null

cd ../addpackages/tarballs/libffmpeg-free-${BOARD}
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
cd ../../ebuilds/chromeos-base
tar cvf - libffmpeg-free | (cd ~/trunk/src/third_party/chromiumos-overlay/chromeos-base; tar xf -)
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to  failed. Abort."
	exit 1
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
        sed -e '/^RDEPEND="${CROS_COMMON_RDEPEND}/a \\tmybuild? ( chromeos-base\/libffmpeg-free )' -i target-chromium-os-1.ebuild || exit 1
        echo done
        revisionup_ebuild
else
        echo libffmpeg-free is already included in base overlay. skip.
fi

search2=`grep -e 'IUSE=.* penm x64c mybuild$' target-chromium-os-1.ebuild`
if [ -z "${search2}" ]; then
	echo add penm/x64c/mybuild to IUSE.
	sed -e 's/\(IUSE=.*$\)/\1 penm x64c mybuild/' -i target-chromium-os-1.ebuild || exit 1
	echo done
else
	echo target-chromium-os-1.ebuild already has penm/x64c/mybuild in IUSE.
fi

popd > /dev/null
