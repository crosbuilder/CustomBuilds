#!/bin/bash

if [ -z ${BOARD} ]; then
  echo "[ERROR] Please set BOARD".
  exit 1
fi

#作業場所はlatest固定
cd ~/trunk/src/build/images/x86-pentiumm/latest

if [ ! -f ./chromiumos_base_image.bin ]; then
  echo chromiumos_base_image.bin not found. Abort.
  exit 1
fi

# baseイメージを使うのでdevイメージはリネームする
if [ -f ./chromiumos_image.bin ]; then
  mv ./chromiumos_image.bin ./chromiumos_image.bin-
  if [ $? -ne 0 ]; then
    echo failed to rename dev image. Abort.
    exit 1
  fi
fi

# baseイメージをimage_to_vm.shが参照するファイル名にシンボリックリンク
ln -s ./chromiumos_base_image.bin ./chromiumos_image.bin
if [ $? -ne 0 ]; then
  echo failed to create symbolic link. Abort.
  exit 1
fi

# VM用イメージ作成
cd ~/trunk/src/scripts
echo start creating vm image...
./image_to_vm.sh --board=${BOARD}
if [ $? -ne 0 ]; then
  echo failed to create vm image. Abort.
  exit 1
fi

# シンボリックリンクを消す
cd ~/trunk/src/build/images/x86-pentiumm/latest
unlink ./chromiumos_image.bin
if [ $? -ne 0 ]; then
  echo failed to remove symbolic link. Abort.
  exit 1
fi


# 退避したイメージを元に戻す
if [ -f ./chromiumos_image.bin- ]; then
  mv ./chromiumos_image.bin- ./chromiumos_image.bin
  if [ $? -ne 0 ]; then
    echo failed to recovery dev image. Abort.
    exit 1
  fi
fi


