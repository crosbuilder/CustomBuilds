#!/bin/bash

if [ -z ${BOARD} ]; then
        echo "[ERROR] Please set BOARD".
        exit
fi

# update_engineパッケージに公開鍵のインストール処理を追加する

# 公開鍵をパッケージディレクトリ配下に置く

echo copy public key to package dir
PACKAGE_DIR=~/trunk/src/third_party/chromiumos-overlay/chromeos-base/update_engine/
cp ~/keys/publickey.pem ${PACKAGE_DIR}/files/update-payload-key.pub.pem

# ebuildファイルに公開鍵のインストール処理を追加するパッチを当てる
echo patching ebuild to install public key.
cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/update_engine/update_engine_ebuild.diff
read -p 'check dry-run patching result and if NG then press Ctrl-C ' status

patch -p1 < ~/myenv/patches/chromiumos-overlay/update_engine/update_engine_ebuild.diff

# update_packageをcros_workon startする
echo cros_workon starting...
cros_workon --board=${BOARD} start chromeos-base/update_engine

