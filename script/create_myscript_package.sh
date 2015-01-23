#!/bin/bash

if [ -z ${BOARD} ]; then
	echo "[ERROR] Please set BOARD".
	exit
fi

# スクリプトをtarにまとめる。このとき、ディレクトリmyscript-1配下にスクリプトが置かれるようにする
pushd . > /dev/null
copydir=~/myenv/addpackages/tarballs/myscript-1
if [ -e ${copydir} ]; then
	rm -rf ${copydir}
fi
mkdir ${copydir}
cp -R ../script_dev/* ${copydir}

cd ${copydir}/..
tar zcvf myscript.tar.gz ./myscript-1
if [ 0 -ne $? ]; then
	echo "[ERROR]Create tar failed. Abort."
	exit
fi


# 作成したtar.gzをキャッシュディレクトリに置く
cp myscript.tar.gz /var/cache/chromeos-cache/distfiles/target/
if [ 0 -ne $? ]; then
	echo "[ERROR]copy tar to cache dir failed. Abort."
	exit
fi


# ebuildを所定の場所に置く
cd ../ebuilds/app-misc
tar cvf - myscript | (cd ~/trunk/src/third_party/portage-stable/app-misc; tar xf -)
if [ 0 -ne $? ]; then
	echo "[ERROR]copy ebuild to portage-stable failed. Abort."
	exit
fi

# portageのパッケージ展開先をクリアしておく
portage_workdir=/build/${BOARD}/tmp/portage/app-misc/myscript-1
if [ -e ${portage_workdir} ]; then
	sudo rm -rf ${portage_workdir}
fi

# ebuildのテストを実行する
cd ~/trunk/src/third_party/portage-stable/app-misc/myscript
rm -f Manifest
ebuild-${BOARD} myscript-1.ebuild manifest
ebuild-${BOARD} myscript-1.ebuild test
emerge-${BOARD} app-misc/myscript --pretend --verbose


popd > /dev/null
