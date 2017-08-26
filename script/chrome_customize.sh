#!/bin/bash

# chromeをcros_workonする
cros_workon --board=x86-pentiumm start chromeos-base/chromeos-chrome

# ebuildにパッチ当てをする(audio/mp3対策、--mno-sse*のフィルタリング )
# x86-genericビルド時のみ。x86-pentiummのビルド時は既にパッチがあたっているのでスキップする
# →あたっていない。BORADによるチェックは廃止
#if [ "${BOARD}" = "x86-generic" ]; then
  cd ~/trunk/src/overlays/overlay-x86-pentiumm
  patch -p1 --dry-run < ~/myenv/patches/chromeos-chrome/chromeos-chrome-9999.ebuild.diff
  if [ $? -ne 0 ]; then
    echo Failed to dry-run patch. Abort.
    exit 1
  fi
  patch -p1 < ~/myenv/patches/chromeos-chrome/chromeos-chrome-9999.ebuild.diff
  if [ $? -ne 0 ]; then
    echo Failed to apply patch. Abort.
    exit 1
  fi
#fi
# ソースに当てるパッチをfilesに配置する
if [ ! -d chromeos-base/chromeos-chrome/files ]; then
  mkdir chromeos-base/chromeos-chrome/files
fi
cd chromeos-base/chromeos-chrome/files

# R43以降でSoftware Compositingがガードされたのを解除するパッチ
cp ~/myenv/patches/chrome_root/src/enable_software_compositor.patch .
# CapsLockキーの設定メニューを表示させるパッチ
cp ~/myenv/patches/chrome_root/src/capslock_setting.diff .
# R52でサスペンドからの復帰後にマウスカーソルが表示されなくなる問題を修正するパッチ
cp ~/myenv/patches/chrome_root/src/resume_mouse_cursor.diff .

# 9999.ebuildを書き換えてcros_workonしていてもgit cloneしてビルドするように指示する
cd ..
sed -e '/^EAPI="4"/a CHROME_ORIGIN=SERVER_SOURCE' -i chromeos-chrome-9999.ebuild

# chromeのバージョンを9999にしておくとmasterから持ってくるのでバージョン付きebuildファイルから最新バージョンを抽出する
CR_VERSION=`ls -1v chromeos-chrome-*.ebuild | grep -v 9999 | tail -n 1 | sed -e 's/chromeos-chrome-//' | sed -e 's/_.*ebuild$//'`
sed -e "s@CHROME_VERSION=\"\${PV/_\*/}\"@CHROME_VERSION=${CR_VERSION}@" -i chromeos-chrome-9999.ebuild

# 適用するパッチを指示する
sed -e 's/^PATCHES=()$/PATCHES=\(${FILESDIR}\/enable_software_compositor.patch ${FILESDIR}\/capslock_setting.diff ${FILESDIR}\/resume_mouse_cursor.diff\)/' -i chromeos-chrome-9999.ebuild

