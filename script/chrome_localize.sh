#!/bin/bash

# chromeをcros_workonする
cros_workon --board=x86-pentiumm start chromeos-base/chromeos-chrome

# chrome本体(chromeos-base/chromeos-chrome)のソースを/home/chromium/chrome_root配下にコピーする。
# cros_workonしたchromeos-chromeは固定で~/chrome_root配下のソースをビルドする要になっている。
chrome_root=/home/chromium/chrome_root
if [ ! -e /home/chromium/chrome_root ]; then
  mkdir ${chrome_root}
fi
cd /var/cache/chromeos-cache/distfiles/target/chrome-src
tar cvf - . | (cd ${chrome_root}; tar xf -)

# ebuildfaにパッチ当てをする(audio/mp3対策、--mno-sse*のフィルタリング )
cd ~/trunk/src/third_party/chromiumos-overlay
patch -p1 < ~/myenv/patches/chromeos-chrome/chromeos-chrome-9999.ebuild.diff
