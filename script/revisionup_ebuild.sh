#!/bin/bash

# カレントディレクトリにあるebuildファイルのシンボリックリンクのリビジョンを上げる
# 処理対象のパッケージディレクトリにcdしてからこのスクリプトを呼ぶ
# シンボリックリンクが複数ある場合はテストしていないので要注意。

revisionup_ebuild() {
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
	
}

