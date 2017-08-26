#!/bin/bash
# Pentium M用のBOARDを作成する

pushd . > /dev/null

# 既にオーバレイディレクトリがあるなら~/myenv/に移動してリネーム。２世代前は消す
if [ -d ~/myenv/overlay-x86-xorg-old ]; then
  rm -rf ~/myenv/overlay-x86-xorg-old 
  echo Delete backup of older xorg board. 
fi
cd ~/trunk/src/overlays
if [ -d overlay-x86-xorg ]; then
  mv overlay-x86-xorg ~/myenv/overlay-x86-xorg-old
  echo Backup old xorg board.
fi

# x86-genericのオーバレイ定義をコピー
cp -r overlay-x86-generic overlay-x86-xorg
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi

# freon->Xorgパッチを当てる
cd overlay-x86-xorg
patch -p1 -R -N --dry-run < ~/myenv/patches/overlays/disable_freon.patch
if [ $? -ne 0 ]; then
  echo Failed to dry-run patch disable Freon. Abort.
  exit 1
fi
patch -p2 --dry-run  < ~/myenv/patches/overlays/disable_freon-2.patch
if [ $? -ne 0 ]; then
  echo Failed to dry-run patch disable Freon. Abort.
  exit 1
fi
patch -p1 -R -N < ~/myenv/patches/overlays/disable_freon.patch
if [ $? -ne 0 ]; then
  echo Failed to apply patch disable Freon. Abort.
  exit 1
fi

patch -p2  < ~/myenv/patches/overlays/disable_freon-2.patch
if [ $? -ne 0 ]; then
  echo Failed to apply patch disable Freon. Abort.
  exit 1
fi

# オーバレイ名を書き換える
cd metadata
sed -e 's/generic/xorg/g' -i layout.conf
if [ 0 -ne $? ]; then
  echo Error occured.  Aborted.
  exit 1
fi


# ~/trunk/src/overlaysでrepo startする
repo start my_overlay .

