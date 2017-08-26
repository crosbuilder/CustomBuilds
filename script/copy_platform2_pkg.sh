#!/bin/bash
myname=$0
cd ${myname%/*}

source ./add_src_prepare_to_ebuild.sh

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
        echo Please set BOARD. Abort.
        exit 1
fi

#パッケージをコピーする
cd ~/trunk/src/overlays/overlay-${BOARD}
if [ ! -d chromeos-base ]; then
  mkdir chromeos-base
  if [ 0 -ne $? ]; then
    echo Failed mkdir chromeos-base. Abort.
    exit 1
  fi
fi

cd chromeos-base

# loginマネージャ用パッケージのコピー
if [ ! -d chromeos-login ]; then
  cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-login .
  if [ 0 -ne $? ]; then
    echo Failed copy chromeos-login pkg. Abort.
    exit 1
  fi
  if [! -d chromeos-login/files ]; then
    mkdir chromeos-login/files
    if [ 0 -ne $? ]; then
      echo Failed mkdir chromeos-login/files. Abort.
      exit 1
    fi
  fi
fi
# login-manager用パッチのコピー
cp ~/myenv/patches/platform2/login_manager_X_ROOT.diff chromeos-login/files
cp ~/myenv/patches/platform2/ui_conf_inspect_hw.diff chromeos-login/files
echo 'src_prepare() {' >> chromeos-login/chromeos-login-9999.ebuild
echo '    epatch "${FILESDIR}"/login_manager_restore_X11_code.diff' >> chromeos-login/chromeos-login-9999.ebuild
echo '    epatch "${FILESDIR}"/ui_conf_inspect_hw.diff' >> chromeos-login/chromeos-login-9999.ebuild
echo '    epatch "${FILESDIR}"/login_manager_X_ROOT.diff' >> chromeos-login/chromeos-login-9999.ebuild
echo '}' >> chromeos-login/chromeos-login-9999.ebuild

# installerパッケージのコピー
if [ ! -d chromeos-installer ]; then
  cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-installer .
  if [ 0 -ne $? ]; then
    echo Failed copy chromeos-installer pkg. Abort.
    exit 1
  fi
  if [ ! -d chromeos-installer/files ]; then
    mkdir chromeos-installer/files
    if [ 0 -ne $? ]; then
      echo Failed mkdir chromeos-installer/files. Abort.
      exit 1
    fi
  fi
fi
# installer用パッチのコピー
cp ~/myenv/patches/platform2/installer_root_uuid.diff chromeos-installer/files
cp ~/myenv/patches/platform2/chromeos-setdevpasswd.diff chromeos-installer/files
cp ~/myenv/patches/platform2/chromeos-installer.diff chromeos-installer/files
add_src_prepare_to_ebuild chromeos-installer/chromeos-installer-9999.ebuild
sed -e '/^EAPI="4"/a CROS_WORKON_ALWAYS_LIVE="1"' -i chromeos-installer/chromeos-installer-9999.ebuild

if [ ! -d chromeos-init ]; then
  cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-init .
  if [ 0 -ne $? ]; then
    echo Failed copy chromeos-init pkg. Abort.
    exit 1
  fi
  if [ ! -d chromeos-init/files ]; then
    mkdir chromeos-init/files
    if [ 0 -ne $? ]; then
      echo Failed mkdir chromeos-init/files. Abort.
      exit 1
    fi
  fi
fi
# init用パッチのコピー 
cp ~/myenv/patches/platform2/preload-network.conf.diff chromeos-init/files
cp ~/myenv/patches/platform2/halt_reboot_conf.diff chromeos-init/files
cp ~/myenv/patches/platform2/boot-splash.diff chromeos-init/files
echo 'src_prepare() {' >> chromeos-init/chromeos-init-9999.ebuild
echo '   epatch ${FILESDIR}/*.diff' >> chromeos-init/chromeos-init-9999.ebuild
echo '   if [ ${S}/upstart/send-boot-mode.conf ]; then' >> chromeos-init/chromeos-init-9999.ebuild
echo '     rm -f ${S}/upstart/send-boot-mode.conf' >> chromeos-init/chromeos-init-9999.ebuild
echo '     if [ 0 -ne $? ]; then' >> chromeos-init/chromeos-init-9999.ebuild
echo '       echo Failed to delete send-boot-mode.conf. Abort.' >> chromeos-init/chromeos-init-9999.ebuild
echo '       exit 1' >> chromeos-init/chromeos-init-9999.ebuild
echo '     fi' >> chromeos-init/chromeos-init-9999.ebuild
echo '   else' >> chromeos-init/chromeos-init-9999.ebuild
echo '     echo ${S}/upstart/send-boot-mode.conf not found. Abort.' >> chromeos-init/chromeos-init-9999.ebuild
echo '     exit 1' >> chromeos-init/chromeos-init-9999.ebuild
echo '   fi' >> chromeos-init/chromeos-init-9999.ebuild
echo '}' >> chromeos-init/chromeos-init-9999.ebuild
sed -e '/^EAPI="4"/a CROS_WORKON_ALWAYS_LIVE="1"' -i chromeos-init/chromeos-init-9999.ebuild

# 以下のスクリプトはAtom N280+945GSEの環境でハングアップや電源断を起こす。品質調査用であり、動作に必須ではないので消す。
#if [ -f ~/trunk/src/platform2/init/upstart/send-boot-mode.conf ]; then
#  rm -f ~/trunk/src/platform2/init/upstart/send-boot-mode.conf
#  if [ 0 -ne $? ]; then
#    echo Failed to delete send-boot-mode.conf. Abort.
#    exit 1
#  fi
#fi

cros_workon --board=${BOARD} start chromeos-base/chromeos-login
if [ 0 -ne $? ]; then
  echo Failed to cros_workon start chromeos-login Abort.
  exit 1
fi
cros_workon --board=${BOARD} start chromeos-base/chromeos-installer
if [ 0 -ne $? ]; then
  echo Failed to cros_workon start chromeos-installer Abort.
  exit 1
fi
cros_workon --board=${BOARD} start chromeos-base/chromeos-init
if [ 0 -ne $? ]; then
  echo Failed to cros_workon start chromeos-init Abort.
  exit 1
fi
cros_workon_make --board=${BOARD} chromeos-base/chromeos-installer --install
if [ 0 -ne $? ]; then
  echo Failed to cros_workon_maket chromeos-installer Abort.
  exit 1
fi

