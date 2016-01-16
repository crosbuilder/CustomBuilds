#!/bin/bash

get_oldroot() {

  rootdrv=`rootdev | grep -o -e '/dev/[a-z]*'`
  partnum=`rootdev | grep -o -e '[35]'`
  if [ ${partnum} -eq 3 ]; then
    oldpartnum=5
  else
    oldpartnum=3
  fi
  echo ${rootdrv}${oldpartnum}
}

get_filesystem() {
  fs=`sudo blkid | grep $1 | grep -o -e 'TYPE="[^\"]*"'`
  echo ${fs}
}

