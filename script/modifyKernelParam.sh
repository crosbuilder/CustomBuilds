#!/bin/bash

source ./path.sh
source ./getKernelSourcePath.sh

# 指定したカーネルパラメータが指定されているconfigファイルを探す
# $1 : パラメータ名
# return : 0：正常 1：エラー
getTargetConfigName(){
	kernel_path=`getKernelSourcePath`

	if [ -z "${kernel_path}" ]; then
		return 1
	fi
#echo root=${SDK_ROOT}
	local kernel_fullpath=${SDK_ROOT}/${kernel_path}
#echo ${kernel_fullpath}

	pushd . > /dev/null

	cd ${kernel_fullpath}/chromeos/config

	local target_line=`find . -name '*.config' -print | grep -e 'base\|i386/' | xargs grep $1`
	local target_configname=${kernel_fullpath}/`echo ${target_line}|cut -d ":" -f 1 `
	echo ${target_configname}

	popd > /dev/null
	return 0
}

# カーネルパラメータの現在の設定を指定した内容に置き換える
# $1 設定する内容：param=valueの形式
# $2 編集する設定ファイル名
modifyKernelParam(){
	echo $1
	echo $2
	local target_param=`echo $1 | cut -d '=' -f 1`
	echo ${target_param}
	local sedscript="s/^.*${target_param}.*$/$1/" 
	echo ${sedscript}
}

modifyKernelParam CONFIG_PATA_ACPI=y ~/myenv/test/common.config
