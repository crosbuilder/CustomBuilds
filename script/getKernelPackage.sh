#!/bin/bash
getKernelPackageName() {
	source ./path.sh
	if [ -z "$BOARD" ]; then
		echo "Prease set BOARD" >&2
		return 1
	fi
#	echo ${BOARD}
	local overlay_name="overlay-${BOARD}"
#	echo ${overlay_name}
	local target_path=${OVERLAY_DIR}/${overlay_name}
#	echo ${target_path}

	# search 
	local make_conf=${target_path}/profiles/base/make.defaults
	
	# get package name list
	local use=`grep -e "^USE=" ${make_conf}`
#	echo ${use}

	local kernel_name=`echo ${use} | grep -o -e "kernel-[0-9_]*"`
	if [ -z "${kernel_name}" ]; then
		echo "[ERROR] Failed to get kernel package name." >&2
		return 1
	fi
	echo ${kernel_name}

	return 0
}

