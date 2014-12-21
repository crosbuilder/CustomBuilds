#!/bin/bash

# ブランチを作成する。
# 既に同一名のブランチが存在する場合は作成をスキップする
# $1 : 作成するブランチの名前
# $2 : ブランチするワークディレクトリのパス
createBranch() {
	pushd . > /dev/null

	cd $2
	pwd

	# $2でrepo startが使えるかチェックする
	repo branches > /dev/null
	if [ 0 -ne $? ]; then
		return $?
	fi

	# 同一名のブランチが存在するかチェックする
	count=`repo branches | grep $1 | wc -l`

	if [ 1 -eq ${count} ]; then
		echo "[ERROR] branch $1 already exists. Skipped."
		return 1
	fi

	# ブランチ作成
	repo start $1 .
	if [ 0 -ne $? ]; then
		return $?
	fi

	popd > /dev/null

	return 0
}

#createBranch $1 $2
