#!/bin/bash

# 実行したスクリプトの履歴を保存する
# $1 履歴に保存するスクリプト起動コマンドライン
addhistory(){
  history=${script_local}/history.sh
  args="$@"
  echo "args=${args}"
  nohis=`echo ${args} | grep nohistory`
  if [ -z "${nohis}" ]; then
    if [ -e ${history} ]; then
      # 既に同じ行が存在するか確認する
      line=`grep "${args}" ${history}`
      if [ -z "${line}" ]; then
        echo ${args} >> ${history}
        echo add shell comand to history.
      else
        echo shell command already exists in history.
      fi
    else
      echo '#!/bin/bash' > ${history}
      echo ${args} >> ${history}
      echo add shell comand to history.
    fi
  fi

}


