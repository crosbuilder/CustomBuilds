#!/bin/bash

# アップデート時のChrome localize

# chrome本体(chromeos-base/chromeos-chrome)のソースを/home/chromium/chrome_root配下にコピーする。
# cros_workonしたchromeos-chromeは固定で~/chrome_root配下のソースをビルドする要になっている。
chrome_root=/home/chromium/chrome_root
chrome_root_old=/home/chromium/chrome_root_old
if [ ! -e /home/chromium/chrome_root ]; then
  mkdir ${chrome_root}
else
  sudo rm -r ${chrome_root_old}
  mv ${chrome_root} ${chrome_root_old}
  mkdir ${chrome_root}
fi
if [ $? -ne 0 ]; then
  echo Failed to initialize localization. Abort.
  exit 1
fi

cd /var/cache/chromeos-cache/distfiles/target/chrome-src
tar cvf - . | (cd ${chrome_root}; tar xf -)

# R43以降でSoftware Compositingがガードされたのを解除する
cd ${chrome_root}/src
patch -p1 < ~/myenv/patches/chrome_root/src/enable_software_compositor.patch
if [ $? -ne 0 ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi
# CapsLockキーの設定メニューを表示させる
patch -p1 < ~/myenv/patches/chrome_root/src/capslock_setting.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi
# R52でサスペンドからの復帰後にマウスカーソルが表示されなくなる問題を修正
patch -p1 -R < ~/myenv/patches/chrome_root/src/resume_mouse_cursor.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi

