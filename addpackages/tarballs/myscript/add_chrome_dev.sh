#!/bin/bash

# /etc/chrome_dev.confに指定した行を追加する。
# 同時に/usr/local/myscript/chrome_dev_historyに同じ内容を追加する。
# どちらに出力する際も重複チェックして同じ行が含まれないようにする
# $1 chrome_dev.confに出力する文字列。空白を含む場合はダブルクォートで囲む
add_chrome_dev() {
  chrome_dev=/etc/chrome_dev.conf
  if [ ! -e ${chrome_dev} ]; then
    echo chrome_dev.conf not found. Abort.
    exit 1
  fi
  line=`grep -- "$1" ${chrome_dev}`
  if [ -z "${line}" ]; then
    mount -o remount,rw /
    if [ 0 -ne $? ]; then
      echo Remount failed. Abort.
      exit 1
    fi
    echo "$1" >> ${chrome_dev}
    echo add line to chrome_dev.conf
  else
    echo same line already exists in chrome_dev.conf 
  fi
  history=${script_local}/chrome_dev_history.sh
  if [ -e ${history} ]; then
    # 既に同じ行が存在するか確認する
    line=`grep -- "$1" ${history}`
    if [ -z "${line}" ]; then
      echo "$1" >> ${history}
      echo add line comand to chrome_dev_history.
    else
      echo same line already exists in chrome_dev_history.
    fi
  else
    echo $1 > ${history}
  fi

}

#script_local=/tmp
#add_chrome_dev "test test"
