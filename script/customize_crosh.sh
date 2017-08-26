#!/bin/bash

# BOARDが無ければ設定を要求する
if [ -z "${BOARD}" ]; then
        echo Please set BOARD. Abort.
        exit 1
fi

#パッケージをコピー
cd ~/trunk/src/overlays/overlay-${BOARD}/chromeos-base
if [ $? -ne 0 ]; then
  echo Failed to chdir overlay-${BOARD}/chromeos-base. Abort.
  exit 1
fi 

cp -r ~/trunk/src/third_party/chromiumos-overlay/chromeos-base/crosh .
if [ $? -ne 0 ]; then
  echo Failed to cp crosh pkg. Abort.
  exit 1
fi 

cd crosh
if [ ! -d files ]; then
  mkdir files
  if [ $? -ne 0 ]; then
    echo Failed to mkdir crosh/files. Abort.
    exit 1
  fi
fi
cp ~/myenv/patches/platform2/crosh.diff files/
if [ $? -ne 0 ]; then
  echo Failed to cp crosh.diff. Abort.
  exit 1
fi

cp -r /mnt/host/source/chroot/home/chromium/myenv/patches/platform2/custom.d files/
if [ $? -ne 0 ]; then
  echo Failed to cp custom.d. Abort.
  exit 1
fi

cd ../..

patch -p1 --dry-run < ~/myenv/patches/chromiumos-overlay/crosh/crosh-9999.ebuild.diff
if [ $? -ne 0 ]; then
  echo Failed to dry-run patches. Abort.
  exit 1
fi

patch -p1 < ~/myenv/patches/chromiumos-overlay/crosh/crosh-9999.ebuild.diff
if [ $? -ne 0 ]; then
  echo Failed to apply patches. Abort.
  exit 1
fi

sed -e '/^EAPI="4"/a CROS_WORKON_ALWAYS_LIVE="1"' -i chromeos-base/crosh/crosh-9999.ebuild
echo 'src_prepare() {' >> chromeos-base/crosh/crosh-9999.ebuild
echo '    epatch ${FILESDIR}/*.diff' >> chromeos-base/crosh/crosh-9999.ebuild
echo '    cp -r ${FILESDIR}/custom.d ${S}/' >> chromeos-base/crosh/crosh-9999.ebuild
echo '}' >> chromeos-base/crosh/crosh-9999.ebuild


#cd ~/trunk/src/platform2/
#patch -p1 --dry-run < ~/myenv/patches/platform2/crosh.diff
#if [ $? -ne 0 ]; then
#  echo Failed to dry-run patches. Abort.
#  exit 1
#fi

#patch -p1 < ~/myenv/patches/platform2/crosh.diff
#if [ $? -ne 0 ]; then
#  echo Failed to apply patches. Abort.
#  exit 1
#fi

#cd /mnt/host/source/src/platform2/crosh
#cp -r /mnt/host/source/chroot/home/chromium/myenv/patches/platform2/custom.d .
#if [ $? -ne 0 ]; then
#  echo Failed to create hard link. Abort.
#  exit 1
#fi

cd ~/trunk/src/scripts

cros_workon --board=${BOARD} start chromeos-base/crosh
if [ $? -ne 0 ]; then
  echo Failed to cros_workon start. Abort.
  exit 1
fi

