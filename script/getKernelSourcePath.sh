#!/bin/bash

source ./getKernelPackage.sh

getKernelSourcePath() {
	local kernel_name=`getKernelPackageName`
	if [ -z "${kernel_name}" ]; then
		return 1
	fi

#echo ${kernel_name}

	local kernel_version=`echo ${kernel_name} | grep -o -e "[0-9]*$"`
#echo ${kernel_version}

	pushd . > /dev/null

	cd ~/trunk/src/scripts
	kernel_source_path=`cros_workon --board=${BOARD} info --all | grep "${kernel_name}" | grep -e "${kernel_version}$" | cut -d " " -f 3`

	if [ -z ${kernel_source_path} ]; then
		echo "[ERROR] Failed to get Kernel Source Path." >&2
		return 1
	fi

	echo ${kernel_source_path}
	popd > /dev/null

	return 0

}

#getKernelSourcePath
