#!/bin/bash

# カレントディレクトリがrepo startされているか調べ、
# まだstart指定なければstartする

branch=`git branch --list | grep $1`
if [ -z "${branch}" ]; then
  repo start $1 .
else
  echo Already repo started. skip.
fi
