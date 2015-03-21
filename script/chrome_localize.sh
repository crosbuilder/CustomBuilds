#!/bin/bash

# chrome本体(chromeos-base/chromeos-chrome)のソースを/home/chromium/chrome_root配下にコピーする。
# cros_workonしたchromeos-chromeは固定で~/chrome_root配下のソースをビルドする要になっている。
chrome_root=/home/chromium/chrome_root
if [ ! -e /home/chromium/chrome_root ]; then
  mkdir ${chrome_root}
fi
cd /var/cache/chromeos-cache/distfiles/target/chrome-src
tar cvf - . | (cd ${chrome_root}; tar xf -)

