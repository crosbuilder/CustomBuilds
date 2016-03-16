#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null

# x86-genericのオーバレイ定義をコピー
cd ~/trunk/src/overlays
cp -r overlay-amd64-generic overlay-amd64-custom
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# USEフラグにx64cとmybuildを追加
cd overlay-amd64-custom
sed -e 's/peerd/peerd x64c mybuild/g' -i make.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# ignore collision of libffmpeg.so and ar
echo 'COLLISION_IGNORE="/usr/lib/libffmpeg.so /usr/bin/ar /etc/nsswitch.conf"' >> make.conf

# broadcom wifi用ファームウェアを追加
sed -e 's/iwlwifi-all/iwlwifi-all brcmfmac-all/g' -i make.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# vesaを追加
cd profiles/base
sed -e 's/radeon/radeon vesa/g' -i make.defaults
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

cd ../..


# オーバレイ名を書き換える
cd metadata
sed -e 's/generic/custom/g' -i layout.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


# ~/trunk/src/overlaysでrepo startする
repo start my_overlay .

# ~/trunk/src/third_party\chromiumos-overlayでrepo startする
cd ~/trunk/src/third_party/chromiumos-overlay
repo start my-chromiumos-overlay .

# cros-board.eclassに新しいboardの名前を登録する
cd eclass
sed -e '/^\tamd64-generic$/a \\tamd64-custom' -i cros-board.eclass
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


read -p 'ready to setup board. continue?' status


# boardのセットアップ
cd ~/trunk/src/scripts
./setup_board --board=amd64-custom
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# x86-pentiummでcros_workon startしているパッケージをamd64-customでもstartする
cros_workon --board=x86-pentiumm list | cut -d "/" -f 2 | xargs -L 1 cros_workon --board=amd64-custom start

# sys-libs/gcc-libsはamd64ではcros_workon startしなくてよいのでstopする
cros_workon --board=amd64-custom stop sys-libs/gcc-libs

popd > /dev/null
