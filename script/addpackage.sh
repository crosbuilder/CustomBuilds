#!/bin/bash

source ./createBranch.sh

# 指定したパッケージをインストールメディアに追加する
# 現状ではportage-stableの下のみを対象にする。
# $1 : パッケージ名:app-arch/p7zipのようにカテゴリ名から指定する。この名前のディレクトリがportage-stableの下に存在している必要がある。
# $2 : 省略可：ビルド前にアップグレードするならupgradeと指定する
addPackage(){

	if [ -z "${BOARD}" ]; then
		echo "Please set BOARD"
		return 1
	fi

	if [ -z "$1" ]; then
		echo "Please specify package name"
		return 1
	fi

	# portage-stableにブランチを作る
	local package_root=~/trunk/src/third_party/portage-stable
	pushd . > /dev/null
	createBranch my_portage ${package_root}
	
	cd ${package_root}/$1
	if [ 0 -ne $? ]; then
		echo "[ERROR] Failed to cd. Abort."
		return 1
	fi

# パッケージをアップグレードする
	if [ -n "$2" ]; then
		if [ $2 = "upgrade" ]; then
			cros_portage_upgrade --board=${BOARD} --upgrade $1
		fi
	fi

# ebuildファイルを探す
	local ebuild_name=`ls *.ebuild`
	if [ -z "${ebuild_name}" ]; then
		echo "[ERROR] ebuild file not found. Abort."
		return 1
	fi

# ビルドする
	ebuild-${BOARD} ${ebuild_name} compile
	if [ 0 -ne $? ]; then
		echo "[ERROR] Failed to build package. Abort."
		return 1
	fi
	echo "Build package succeeded."

# chromiumos-overlayに追加する
	echo "Add package to overay ebuild file..."
	local overlay_dir=~/trunk/src/third_party/chromiumos-overlay/virtual/target-chromium-os-dev
    createBranch my-overlay ${overlay_dir}
	cd ${overlay_dir}
	local overlay_ebuild=`ls -1 | grep -e '.*-[0-9]*\.ebuild'`
	sed -e "/^RDEPEND=\"\${RDEPEND}/a \\\t$1" -i ${overlay_ebuild}
	if [ 0 -ne $? ]; then
		echo "[ERROR] Failed to add package name to ebuild file. Abort."
		return 1
	fi
	echo "Done."

# シンボリックリンクのリビジョンを上げる
	echo "Revision up ebuild file..."
	local overlay_symlink=`ls -1 | grep -e '.*-r[0-9]*\.ebuild'`
	local symlink_prefix=`echo ${overlay_symlink} | grep -E -o '.*-r'`
	local rev=`echo ${overlay_symlink} | grep -E -o '[0-9]*.ebuild' | cut -d '.' -f 1`

	local newrev=$(( rev + 1 ))
	local new_symlink=${symlink_prefix}${newrev}.ebuild

	mv ${overlay_symlink} ${new_symlink}
	if [ 0 -ne $? ]; then
		echo "[ERROR] Failed to rename ebuild file"
		return 1
	fi

	echo "Revision changed r${rev} -> r${newrev}"


	popd > /dev/null

}

addPackage $1 $2
