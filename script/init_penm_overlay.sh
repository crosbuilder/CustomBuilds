#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null

# 既にオーバレイディレクトリがあるなら~/myenv/に移動してリネーム。２世代前は消す
if [ -d ~/myenv/overlay-x86-pentiumm-old ]; then
  rm -rf ~/myenv/overlay-x86-pentiumm-old 
  echo Delete backup of older pentiumm board. 
fi
cd ~/trunk/src/overlays
if [ -d overlay-x86-pentiumm ]; then
  mv overlay-x86-pentiumm ~/myenv/overlay-x86-pentiumm-old
  echo Backup old pentiumm board.
fi

# x86-xorgのオーバレイ定義をコピー
cp -r overlay-x86-xorg overlay-x86-pentiumm
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

cd overlay-x86-pentiumm
# コンパイルフラグからsse3を除去する
sed -e 's/-msse3/-mno-sse3 -mno-ssse3 -mno-sse4.2/g' -i make.conf

if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# ignore collision of libffmpeg.so and ar
echo 'COLLISION_IGNORE="${COLLISION_IGNORE} /usr/lib/libffmpeg.so /usr/bin/ar /etc/nsswitch.conf /usr/lib/debug/.build-id"' >> make.conf

# USEフラグにpenm,mybuild,xaを追加
cd profiles/base
sed -e 's/peerd/peerd penm mybuild xa/g' -i make.defaults
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi
# wifi_bootstrappingを除去する
sed -e 's/wifi_bootstrapping//g' -i make.defaults
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


# broadcom wifi用ファームウェアを追加
sed -e 's/iwlwifi-all/iwlwifi-all brcmfmac-all/g' -i make.defaults
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


# vesa, vmware, vmmouseを追加
sed -e 's/radeon/radeon vesa vmware/g' -e '/^VIDEO_CARDS=/a INPUT_DEVICES="${INPUT_DEVICES} vmmouse"' -i make.defaults
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# 使用するkernel定義を変更する

sed -e 's/CHROMEOS_KERNEL_SPLITCONFIG="chromiumos-i386"/CHROMEOS_KERNEL_SPLITCONFIG="chromiumos-x86-pentiumm"/' -i make.defaults

cd ../..


# オーバレイ名を書き換える
cd metadata
sed -e 's/xorg/pentiumm/g' -i layout.conf
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
count=` grep x86-pentiumm ~/trunk/src/third_party/chromiumos-overlay/eclass/cros-board.eclass | wc -l`
if [ "${count}" = "0" ]; then
  sed -e '/^\tx86-generic$/a \\tx86-pentiumm' -i cros-board.eclass
  if [ 0 -ne $? ]; then
    echo Error occured.  Aborted.
    exit 1
  fi
fi

#read -p 'ready to setup board. continue?' status


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

# x86-xorgでcros_workon startしているパッケージをx86-pentiummでもstartする
cros_workon --board=x86-xorg list | cut -d "/" -f 2 | xargs -L 1 cros_workon --board=x86-pentiumm start

popd > /dev/null
