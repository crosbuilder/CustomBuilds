#!/bin/bash
myname=$0
cd ${myname%/*}

. ./path.sh
. ./getKernelPackage.sh

kernel_name=`getKernelPackageName`
if [ -z "${kernel_name}" ]; then
  exit 1
fi

echo ${kernel_name}

echo Apply Kernel Patches
cd /home/chromium/myenv/patches/${kernel_name}

make dryrun
if [ 0 -ne $? ]; then
  echo Failed to dryrun. Abort.
  exit 1
fi
make apply
if [ 0 -ne $? ]; then
  echo Failed to patch. Abort.
  exit 1
fi

# cros_workonはexecKernelReconst.shで実行する。
