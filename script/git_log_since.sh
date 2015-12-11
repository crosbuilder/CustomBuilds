#!/bin/bash
# 以下のようにして、指定日付以降のコミットがあるかを一括検索する
# find . -mexdepth 1 -exec ~/myenv/script/git_log_since.sh {} "yyyy-mm-dd HH:MM:SS" \; | less
cd $1
git log  --since="$2"
