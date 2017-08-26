#!/bin/bash

if [ -z ${BOARD} ]; then
        echo "[ERROR] Please set BOARD".
        exit 1
fi

# update_engineパッケージに公開鍵のインストール処理を追加する

# パッケージをオーバレイにコピーする
PACKAGE_SRC_DIR=~/trunk/src/third_party/chromiumos-overlay/chromeos-base/update_engine/
PACKAGE_PARENT_DIR=~/trunk/src/overlays/overlay-${BOARD}/chromeos-base/
cp -r ${PACKAGE_SRC_DIR} ${PACKAGE_PARENT_DIR}

# 公開鍵をパッケージディレクトリ配下に置く
PACKAGE_DIR=${PACKAGE_PARENT_DIR}/update_engine/
echo copy public key to package dir
cp ~/keys/publickey.pem ${PACKAGE_DIR}/files/update-payload-key.pub.pem
if [ 0 -ne $? ]; then
  echo copy public key failed. please check public key file in ~/keys
  exit 1
fi

# ebuildファイルに公開鍵のインストール処理を追加するパッチを当てる
echo patching ebuild to install public key.
cd ~/trunk/src/overlays/overlay-${BOARD}/
patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/update_engine/update_engine_ebuild.diff
if [ 0 -ne $? ]; then
  echo Failed to dry-run patch. Abort.
  exit 1
fi

patch -p1 < ~/myenv/patches/chromiumos-overlay/update_engine/update_engine_ebuild.diff
if [ 0 -ne $? ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi

# update_packageをcros_workon startする
echo cros_workon starting...
cros_workon --board=${BOARD} start chromeos-base/update_engine

