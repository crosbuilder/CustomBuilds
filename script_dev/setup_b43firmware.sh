#!/bin/bash

cd `dirname $0`
source script_root.sh
source addhistory.sh

#addhistory $0 "$@"

# remount root rw
mount -o remount,rw /

BACKUPDIR=/mnt/stateful_partition/dev_image/myscript/b43
FIRMWARE_ARCHIVE=broadcom-wl-6.30.163.46.tar.bz2
FIRMWARE_FILE=broadcom-wl-6.30.163.46.wl_apsta.o

# /mnt/stateful_partition/dev_image/myscript/firmware/b43 があるかチェックする
if [ -d ${BACKUPDIR} ]; then
  # 見つかったならインストールして終了
  echo The backup of B43 firmware found. installing...
  cp -r ${BACKUPDIR} /lib/firmware
  if [ $? -eq 0 ]; then
    echo Firmware installed.
    exit 0
  else
    echo Failed to install firmware. Abort.
    exit 1
  fi
  
fi

# nohistoryが指定されている場合はバックアップがなければファームウェアをインストールするようにメッセージを出して終了
nohis=`echo $@ | grep nohistory`

if [ -n "${nohis}" ]; then
  echo 
  echo =======================================================
  echo Broadcom Wireless Chip requires the firmware.
  echo The firmware is not included because of license issues.
  echo Please install it manually.
  echo See http://chromiumosde.gozaru.jp/b43firmware.html
  echo =======================================================
  echo 
  exit 0
fi 

# nohistoryが指定されていない場合はリムーバブルメディアを検索してファームウェアアーカイブがあるか調べる。
# ネットワークがない状態ではログインができず、リムーバブルメディアの自動マウントは動かないので自分で探すしかない。
# まずリムーバブルメディアの一覧を取る
echo Search for firmware archive on removable media...
mkdir /tmp/_mnt
dbus-send --system --dest=org.chromium.CrosDisks --type=method_call --print-reply /org/chromium/CrosDisks org.chromium.CrosDisks.EnumerateAutoMountableDevices | grep -e '^ *string' | grep -v '/ata' | grep -o -e '/[^/]*"$' | sed -e 's/"//'  | while read mountable; do
  mount /dev/${mountable} /tmp/_mnt 2>/dev/null
  if [ $? -eq 0 ]; then
    # マウントできたならファイルがあるか探す
    if [ -e /tmp/_mnt/${FIRMWARE_ARCHIVE} ]; then
      # 見つかったらscript_localの下にコピーする
      echo The firmware archive found. Copy to internal disk.
      cp /tmp/_mnt/${FIRMWARE_ARCHIVE} ${script_local}/
      umount /tmp/_mnt
      break;
    fi
    umount /tmp/_mnt
  fi
done
# script_localにファームウェアアーカイブがあるか調べる
cd ${script_local}
if [ ! -e ./${FIRMWARE_ARCHIVE} ]; then
  # ない場合はダウンロードを試みる
  echo Firmware archive not found.
  echo Trying to download firmware...
  wget http://www.lwfinger.com/b43-firmware/${FIRMWARE_ARCHIVE}
  if [ $? -ne 0 ]; then
    echo Failed to download firmware. Abort.
    exit 1
  fi
  echo Done.
  
fi

# 再度ダウンロードディレクトリにファームウェアアーカイブがあるか調べる
if [ ! -e ./${FIRMWARE_ARCHIVE} ]; then
  echo Firmware archive does not found. Abort.
  exit 1
fi

# ファームウェアアーカイブを展開
echo Get firmware object file from archive..
tar jxf ./${FIRMWARE_ARCHIVE}
if [ $? -ne 0 ]; then
  echo Failed to get firmware object file. Abort.
  exit 1
fi
echo Done.

# b43-fwcutterでファームウェアを切り出す
echo Extract firmware from object file...
b43-fwcutter -w ${script_local} ${FIRMWARE_FILE}
if [ $? -ne 0 ]; then
  echo b43-fwcutter failed. Abort.
  exit 1
fi
echo Done.

# 切り出したファームウェアをインストールする
echo Install firmware...
cp -r ${BACKUPDIR} /lib/firmware
if [ $? -ne 0 ]; then
  echo Failed to install. Abort.
  exit 1
fi

echo Done. Please reboot.

exit 0

