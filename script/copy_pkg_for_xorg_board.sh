#!/bin/bash
# x86-xorg board で書き換えるパッケージをオーバレイディレクトリにコピーして修正を加える

pushd . > /dev/null

# 手を加えるパッケージをオーバレイディレクトリにコピーする
cd ~/trunk/src/overlays/overlay-x86-xorg
if [ 0 -ne $? ]; then
  echo cd overlay-x86-xorg failed.  Aborted.
  exit 1
fi

mkdir chromeos-base
if [ 0 -ne $? ]; then
  echo mkdir chromeos-base failed.  Aborted.
  exit 1
fi

cd chromeos-base
cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/power_manager .
if [ 0 -ne $? ]; then
  echo cp power_manager pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-chrome .
if [ 0 -ne $? ]; then
  echo cp chromeos-chrome pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-login .
if [ 0 -ne $? ]; then
  echo cp chromeos-login pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/libchromeos-ui .
if [ 0 -ne $? ]; then
  echo cp libchromeos-ui pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-init .
if [ 0 -ne $? ]; then
  echo cp chromeos-init pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-initramfs .
if [ 0 -ne $? ]; then
  echo cp chromeos-initramfs pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-installshim .
if [ 0 -ne $? ]; then
  echo cp chromeos-installshim pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/common-assets .
if [ 0 -ne $? ]; then
  echo cp common-assets pkg failed.  Aborted.
  exit 1
fi

cd ..
mkdir virtual
cd virtual
cp -r ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os .
if [ 0 -ne $? ]; then
  echo cp target-chromium-os pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os-dev .
if [ 0 -ne $? ]; then
  echo cp target-chromium-os pkg failed.  Aborted.
  exit 1
fi

cp -r ~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os-test .
if [ 0 -ne $? ]; then
  echo cp target-chromium-os pkg failed.  Aborted.
  exit 1
fi

cd ..
mkdir x11-drivers
if [ 0 -ne $? ]; then
  echo mkdir x11-drivers failed.  Aborted.
  exit 1
fi

cd x11-drivers
cp -r ~/trunk/src/third_party/portage-stable/x11-drivers/xf86-input-synaptics .
if [ 0 -ne $? ]; then
  echo cp xf86-input-synaptics pkg failed.  Aborted.
  exit 1
fi

cd ..
cp -r ~/myenv/addpackages/ebuilds/media-gfx .

# パッケージにパッチを当てる
patch -p1 -R --dry-run < ~/myenv/patches/chromiumos-overlay/power_manager/power_manager-9999.ebuild.diff
if [ 0 -ne $? ]; then
  echo dry-run patch to power_manager-9999.ebuild failed.  Aborted.
  exit 1
fi

patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/virtual/target-chromium-os-1.ebuild.diff
if [ 0 -ne $? ]; then
  echo dry-run patch to target-chromium-os failed.  Aborted.
  exit 1
fi

patch -p1 -R --dry-run < ~/myenv/patches/chromeos-chrome/chromeos-chrome-9999.ebuild-2.diff
if [ $? -ne 0 ]; then
  echo dry-run patch to chromeos-chrome-9999.ebuild failed.
  exit 1
fi

patch -p1 --dry-run < ~/myenv/patches/portage-stable/synaptic-compile-error.diff
if [ $? -ne 0 ]; then
  echo dry-run patch to xf86-input-synaptics failed.
  exit 1
fi

patch -p1 -R --dry-run < ~/myenv/patches/chromiumos-overlay/chromeos-base/restore_ply-image.diff
if [ $? -ne 0 ]; then
  echo dry-run patch for restore ply-image failed.
  exit 1
fi

patch -p1 -R < ~/myenv/patches/chromiumos-overlay/power_manager/power_manager-9999.ebuild.diff
if [ 0 -ne $? ]; then
  echo apply patch to power_manager-9999.ebuild failed.  Aborted.
  exit 1
fi

patch -p1 < ~/myenv/patches/chromiumos-overlay/virtual/target-chromium-os-1.ebuild.diff
if [ 0 -ne $? ]; then
  echo apply patch to target-chromium-os failed.  Aborted.
  exit 1
fi

patch -p1 -R < ~/myenv/patches/chromeos-chrome/chromeos-chrome-9999.ebuild-2.diff
if [ $? -ne 0 ]; then
  echo apply patch to chromeos-chrome-9999.ebuild failed.
  exit 1
fi

patch -p1 < ~/myenv/patches/portage-stable/synaptic-compile-error.diff
if [ $? -ne 0 ]; then
  echo apply patch to xf86-input-synaptics failed.
  exit 1
fi

patch -p1 -R < ~/myenv/patches/chromiumos-overlay/chromeos-base/restore_ply-image.diff
if [ $? -ne 0 ]; then
  echo apply patch for restore ply-image failed.
  exit 1
fi

# ビルド時に適用するパッチをパッケージに追加する
cd chromeos-base/chromeos-login/files
cp ~/myenv/patches/platform2/login_manager_restore_X11_code.diff .
cd ..
echo 'src_prepare() {' >> chromeos-login-9999.ebuild
echo '    epatch ${FILESDIR}/*.diff' >> chromeos-login-9999.ebuild
echo '}' >> chromeos-login-9999.ebuild
sed -e '/^EAPI=4/a CROS_WORKON_ALWAYS_LIVE="1"' -i chromeos-login-9999.ebuild

cd ../libchromeos-ui
mkdir files
cd files
cp ~/myenv/patches/platform2/libchromeos-ui_restore_X11_code.diff .
cd ..
echo 'src_prepare() {' >> libchromeos-ui-9999.ebuild
echo '    epatch ${FILESDIR}/*.diff' >> libchromeos-ui-9999.ebuild
echo '}' >> libchromeos-ui-9999.ebuild 
sed -e '/^EAPI=4/a CROS_WORKON_ALWAYS_LIVE="1"' -i libchromeos-ui-9999.ebuild

cd ../power_manager/files
cp ~/myenv/patches/platform2/power_manager_restore_X11_code.diff .
cd ..
echo 'src_prepare() {' >> power_manager-9999.ebuild
echo '    epatch ${FILESDIR}/*.diff' >> power_manager-9999.ebuild
echo '}' >> power_manager-9999.ebuild
sed -e '/^EAPI=4/a CROS_WORKON_ALWAYS_LIVE="1"' -i power_manager-9999.ebuild

# ビルド時にパッチを当てるパッケージはcros_workonする
cros_workon --board=x86-xorg start chromeos-base/chromeos-login
cros_workon --board=x86-xorg start chromeos-base/libchromeos-ui
cros_workon --board=x86-xorg start chromeos-base/power_manager
cros_workon --board=x86-xorg start chromeos-base/chromeos-chrome
cros_workon --board=x86-xorg start chromeos-base/chromeos-init
cros_workon --board=x86-xorg start chromeos-base/chromeos-initramfs
cros_workon --board=x86-xorg start chromeos-base/common-assets
#chromeos-installshim はcros_workonを継承していないので対象外

# chromeのソースをコピーする

chrome_root=/home/chromium/chrome_root
if [ ! -e /home/chromium/chrome_root ]; then
  mkdir ${chrome_root}
else
  mv ${chrome_root} ${chrome_root_old}
fi
cd /var/cache/chromeos-cache/distfiles/target/chrome-src
tar cvf - . | (cd ${chrome_root}; tar xf -)

popd > /dev/null
