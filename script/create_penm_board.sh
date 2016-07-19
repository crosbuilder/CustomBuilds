#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null

# x86-genericのオーバレイ定義をコピー
cd ~/trunk/src/overlays
cp -r overlay-x86-generic overlay-x86-pentiumm
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# freon->Xorgパッチを当てる
# R50以降はx86-genericでfreon->Xorgを試しているはずなので削除
cd overlay-x86-pentiumm
#patch -p1 -R -N < ~/myenv/patches/overlays/disable_freon.patch
#if [ $? -ne 0 ]; then
#  echo Failed to patch disable Freon. Abort.
#  exit 1
#fi

# コンパイルフラグからsse3を除去する
#sed -e 's/-msse3/-mno-sse3 -mno-ssse3 -mno-sse4.2/g' -e 's/^CHROMEOS_KERNEL_SPLITCONFIG="chromiumos-i386"$/CHROMEOS_KERNEL_SPLITCONFIG="chromiumos-pentiumm"/' -i make.conf
sed -e 's/-msse3/-mno-sse3 -mno-ssse3 -mno-sse4.2/g' -i make.conf

if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# USEフラグにpenm,mybuild,xaを追加
sed -e 's/peerd/peerd penm mybuild xa/g' -i make.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi
# wifi_bootstrappingを除去する
sed -e 's/wifi_bootstrapping//g' -i make.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# ignore collision of libffmpeg.so and ar
echo 'COLLISION_IGNORE="${COLLISION_IGNORE} /usr/lib/libffmpeg.so /usr/bin/ar /etc/nsswitch.conf /usr/lib/debug/.build-id"' >> make.conf

# broadcom wifi用ファームウェアを追加
sed -e 's/iwlwifi-all/iwlwifi-all brcmfmac-all/g' -i make.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


# vesa, vmware, vmmouseを追加
cd profiles/base
sed -e 's/radeon/radeon vesa vmware/g' -e '/^VIDEO_CARDS=/a INPUT_DEVICES="${INPUT_DEVICES} vmmouse"' -i make.defaults
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

cd ../..


# オーバレイ名を書き換える
cd metadata
sed -e 's/generic/pentiumm/g' -i layout.conf
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
sed -e '/^\tx86-generic$/a \\tx86-pentiumm' -i cros-board.eclass
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


read -p 'ready to setup board. continue?' status


# boardのセットアップ
cd ~/trunk/src/scripts
./setup_board --board=x86-pentiumm --nousepkg
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# glibcをビルドし直す(SSE3対策)
# まずpackage.providedからglibcのエントリを消す
sudo sed -e '/.*\/glibc.*/d' -i /build/x86-pentiumm/etc/portage/profile/package.provided

FEATURES="-collision-detect -protect-owned" emerge-x86-pentiumm sys-libs/glibc

# x86-genericでcros_workon startしているパッケージをx86-pentiummでもstartする
cros_workon --board=x86-generic list | cut -d "/" -f 2 | xargs -L 1 cros_workon --board=x86-pentiumm start

popd > /dev/null
