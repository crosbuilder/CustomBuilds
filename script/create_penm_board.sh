#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null

# x86-genericのオーバレイ定義をコピー
cd ~/trunk/src/overlays
cp -r overlay-x86-generic overlay-x86-pentiumm

# コンパイルフラグからsse3を除去する
cd overlay-x86-pentiumm
#sed -e 's/-msse3/-mno-sse3 -mno-ssse3 -mno-sse4.2/g' -e 's/^CHROMEOS_KERNEL_SPLITCONFIG="chromiumos-i386"$/CHROMEOS_KERNEL_SPLITCONFIG="chromiumos-pentiumm"/' -i make.conf
sed -e 's/-msse3/-mno-sse3 -mno-ssse3 -mno-sse4.2/g' -i make.conf

# USEフラグにpenmを追加
sed -e 's/peerd/peerd penm/g' -i make.conf

# vesaを追加
sed -e 's/radeon/radeon vesa/g' -i make.conf


# ignore collision of libffmpegsumo.so
echo 'COLLISION_IGNORE="/usr/lib/libffmpeg.so"' >> make.conf

# オーバレイ名を書き換える
cd metadata
sed -e 's/generic/pentiumm/g' -i layout.conf

# ~/trunk/src/overlaysでrepo startする
repo start my_overlay .

# ~/trunk/src/third_party\chromiumos-overlayでrepo startする
cd ~/trunk/src/third_party/chromiumos-overlay
repo start my-chromiumos-overlay .

# cros-board.eclassに新しいboardの名前を登録する
cd eclass
sed -e '/^\tx86-generic$/a \\tx86-pentiumm' -i cros-board.eclass

read -p 'ready to setup board. continue?' status


# boardのセットアップ
cd ~/trunk/src/scripts
./setup_board --board=x86-pentiumm --nousepkg

# x86-genericでcros_workon startしているパッケージをx86-pentiummでもstartする
cros_workon --board=x86-generic list | cut -d "/" -f 2 | xargs -L 1 cros_workon --board=x86-pentiumm start

popd > /dev/null
