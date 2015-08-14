#!/bin/bash

# 実行したスクリプトの履歴から指定した行を削除する
# $1 履歴から削除するスクリプト起動コマンドライン
delhistory(){
  history=${script_local}/history.sh
  args="$@"
  echo "args=${args}"
  if [ -e ${history} ]; then
    # 既に同じ行が存在するか確認する
    line=`grep "${args}" ${history}`
    if [ -n "${line}" ]; then
      delline=`echo ${line} | sed -e 's@/@\\\\/@g'`
      sed -e "/${delline}/d" -i ${history}
      if [ 0 -ne $? ]; then
        echo Failed to delete shell command from history. abort.
	exit 1
      fi
      echo delete shell command from history.
    else
      echo specified shell command not found history.
    fi
  else
    echo ${history} not found.
  fi

}

