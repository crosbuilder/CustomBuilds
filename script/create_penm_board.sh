#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null

# x86-genericのオーバレイ定義をコピー
cd ~/trunk/src/overlays
cp -r overlay-x86-generic overlay-x86-pentiumm

# コンパイルフラグからsse3を除去する
cd overlay-x86-pentiumm
sed -e 's/-msse3/-mno-sse3/g' -i make.conf

# オーバレイ名を書き換える
cd metadata
sed -e 's/generic/pentiumm/g' -i layout.conf

# cros-board.eclassに新しいboardの名前を登録する
cd ~/trunk/src/third_party/chromiumos-overlay/eclass
sed -e '/^\tx86-generic$/a \\tx86-pentiumm' -i cros-board.eclass

read -p 'ready to setup board. continue?' status

# boardのセットアップ
cd ~/trunk/src/scripts
./setup_board --board=x86-pentiumm

# x86-genericでcros_workon startしているパッケージをx86-pentiummでもstartする
cros_workon --board=x86-generic list | cut -d "/" -f 2 | xargs -L 1 cros_workon --board=x86-pentiumm start

popd > /dev/null
