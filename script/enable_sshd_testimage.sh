#!/bin/bash
myname=$0
cd ${myname%/*}

if [ -z ${BOARD} ]; then
  echo "[ERROR] Please set BOARD".
  exit 1
fi

~/trunk/src/scripts/mount_gpt_image.sh --board=${BOARD} -f ~/trunk/src/build/images/${BOARD}/latest/chromiumos_test_image.bin

if [ $? -ne 0 ]; then
  echo mount image failed. Abort.
  exit 1
fi


# comment out inspect_hw.sh
sudo sed -e '1,$s@/opt/myscript/inspect_hw.sh@#/opt/myscript/inspect_hw.sh@' -i /tmp/m/etc/init/ui.conf
if [ $? -ne 0 ]; then
  echo mount image failed. Abort.
  exit 1
fi

cd /tmp/m/usr/lib/xorg/modules/drivers
if [ -f vesa_drv.so ]; then
  sudo mv vesa_drv.so vesa_drv.so-
  if [ $? -ne 0 ]; then
    echo mv failed. Abort.
    exit 1
  fi
fi

cd /tmp/m/etc/init
if [ ! -e ./openssh-server.conf ]; then
  sudo ln -s ../../usr/share/chromeos-ssh-config/init/openssh-server.conf .
  if [ $? -ne 0 ]; then
    echo ln -s failed. Abort.
    exit 1
  fi
fi

cd ~/trunk/src/scripts
./mount_gpt_image.sh --board=${BOARD} -u
