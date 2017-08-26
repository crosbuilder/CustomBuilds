#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null


# ~/trunk/src/third_party\chromiumos-overlayでrepo startする
cd ~/trunk/src/third_party/chromiumos-overlay
repo start my-chromiumos-overlay .

# cros-board.eclassに新しいboardの名前を登録する
cd eclass
count=` grep x86-xorg ~/trunk/src/third_party/chromiumos-overlay/eclass/cros-board.eclass | wc -l`
if [ "${count}" = "0" ]; then
  sed -e '/^\tx86-generic$/a \\tx86-xorg' -i cros-board.eclass
  if [ 0 -ne $? ]; then
    echo Error occured.  Aborted.
    exit 1
  fi
fi

read -p 'ready to setup board. continue?' status


# boardのセットアップ
cd ~/trunk/src/scripts
./setup_board --board=x86-xorg --nousepkg
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

popd > /dev/null
