#!/bin/bash -x
myname=$0
cd ${myname%/*}

. ./path.sh
. ./getKernelSourcePath.sh
. ./getKernelPackage.sh
. ./createBranch.sh

# カーネルソースディレクトリの取得
kernel_path=`getKernelSourcePath`
if [ 0 -ne $? ]; then
	exit 1
fi

# cros_workon startが実行されているか調べる
kernel_package=`getKernelPackageName`
if [ 0 -ne $? ]; then
	exit 1
fi
pushd . > /dev/null
cd ~/trunk/src/scripts
workon_status=`cros_workon --board=${BOARD} list | grep ${kernel_package} | wc -l`
if [ 0 -ne $? ]; then
	exit 1
fi
if [ 0 -eq ${workon_status} ]; then
	echo "cros_workon start to ${kernel_package}"
	cros_workon --board=${BOARD} start ${kernel_package}
fi
if [ 0 -ne $? ]; then
	exit 1
fi

popd > /dev/null
pushd . > /dev/null
# ブランチの作成
createBranch mykernel ${kernel_path}
#if [ 0 -ne $? ]; then
#	exit 1
#fi
# BOARD用のflavour.configをコピーする
popd > /dev/null
tokens=( `echo ${BOARD}|tr -s '-' ' '` )
if [ "${tokens[0]}" = "x86" ]; then
  ARCH="i386"
elif [ "${tokens[0]}" = "amd64" ]; then
  ARCH="x86_64"
fi

cp ${kernel_path}/chromeos/config/${ARCH}/chromiumos-${ARCH}.flavour.config ${kernel_path}/chromeos/config/${ARCH}/chromiumos-${BOARD}.flavour.config
cat ~/myenv/kernel_params/${BOARD} | xargs -L 1 ./modifyFlavourConfig.sh

# kernelconfigの実行
pushd . > /dev/null
cd ${kernel_path}/chromeos/scripts
./kernelconfig oldconfig
popd > /dev/null
