#!/bin/bash

# flavour.configに独自カーネルパラメータ設定を反映する。
# 引数：$1："カーネルパラメータ名=値"の形式でパラメータと設定値を指定する

if [ $# -ne 1 ]; then
  echo ERROR: arg1 not specified
  exit 1
fi

source ./path.sh
source ./getKernelSourcePath.sh

kernel_fullpath=`getKernelSourcePath`

if [ -z "${kernel_fullpath}" ]; then
  exit 1
fi

arch="i386"
if [ $(echo ${BOARD} | grep -e 'amd64') ]; then
  arch="x86_64"
fi

target_configname=${kernel_fullpath}/chromeos/config/${arch}/chromiumos-${BOARD}.flavour.config

target_param=`echo $1 | cut -d '=' -f 1`

found=`grep ${target_param} ${target_configname} | wc -l`

if [ ${found} -eq 0 ]; then
  echo $1 >> ${target_configname}
else
  sedscript="s/^.*${target_param}=.*\$/$1/"
  sed -e "${sedscript}" -i ${target_configname}
fi
