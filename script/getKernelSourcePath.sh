#!/bin/bash

source ./path.sh
source ./getKernelPackage.sh

# ${BOARD}�ǻ��ꤵ�줿�����Х쥤�ǻ��Ѥ��Ƥ��륫���ͥ�Υ������ǥ��쥯�ȥ���������
getKernelSourcePath() {
	# 
	if [ -n "${KERNEL_SOURCE_FULLPATH}" ]; then
		echo ${KERNEL_SOURCE_FULLPATH}
		return 0
	fi

	local kernel_name=`getKernelPackageName`
	if [ -z "${kernel_name}" ]; then
		return 1
	fi

#echo ${kernel_name}

	local kernel_version=`echo ${kernel_name} | grep -o -e "[0-9]*$"`
#echo ${kernel_version}

	pushd . > /dev/null

	cd ~/trunk/src/scripts
	local kernel_source_path=`cros_workon --board=${BOARD} info --all | grep "${kernel_name}" | grep -e "${kernel_version}$" | cut -d " " -f 3`

	if [ -z ${kernel_source_path} ]; then
		echo "[ERROR] Failed to get Kernel Source Path." >&2
		return 1
	fi

	KERNEL_SOURCE_FULLPATH=${SDK_ROOT}/${kernel_source_path}
	echo ${KERNEL_SOURCE_FULLPATH}
	popd > /dev/null

	return 0

}

getKernelSourcePath