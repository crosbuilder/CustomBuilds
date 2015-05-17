#!/bin/bash

# 実行したスクリプトの履歴を保存する
# $1 履歴に保存するスクリプト起動コマンドライン
addhistory(){
  history=${script_local}/history.sh
  if [ -e ${history} ]; then
    # 既に同じ行が存在するか確認する
    line=`grep $1 ${history}`
    if [ -z "${line}" ]; then
      echo $1 >> ${history}
      echo add shell comand to history.
    else
      echo shell command already exists in history.
    fi
  else
    echo '#!/bin/bash' > ${history}
    echo $1 >> ${history}
  fi

}


