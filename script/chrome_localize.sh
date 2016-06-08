#!/bin/bash

# chromeをcros_workonする
cros_workon --board=x86-pentiumm start chromeos-base/chromeos-chrome

# chrome本体(chromeos-base/chromeos-chrome)のソースを/home/chromium/chrome_root配下にコピーする。
# cros_workonしたchromeos-chromeは固定で~/chrome_root配下のソースをビルドする要になっている。
chrome_root=/home/chromium/chrome_root
if [ ! -e /home/chromium/chrome_root ]; then
  mkdir ${chrome_root}
else
  mv ${chrome_root} ${chrome_root_old}
fi
cd /var/cache/chromeos-cache/distfiles/target/chrome-src
tar cvf - . | (cd ${chrome_root}; tar xf -)

# ebuildにパッチ当てをする(audio/mp3対策、--mno-sse*のフィルタリング )
cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 < ~/myenv/patches/chromeos-chrome/chromeos-chrome-9999.ebuild.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patch. Abort.
  exit 1
fi

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
