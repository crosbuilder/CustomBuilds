#!/bin/bash

# $1で指定したebuildファイルにsrc_prepare関数とepatch文を追加する
add_src_prepare_to_ebuild(){

  local prepare_count=`grep src_prepare $1 | wc -l`
  local epatch_count=`grep epatch $1 | wc -l`
  if [ ${prepare_count} -eq 0 ]; then
    echo 'src_prepare() {' >> $1
    echo '    epatch "${FILESDIR}"/*.diff' >> $1
    echo '}' >> $1
  elif [ ${epatch_count} -eq 0 ]; then
    sed -e '/^src_prepare() {/a epatch "${FILESDIR}"/*.diff' -i $1
  fi
}

#add_src_prepare_to_ebuild $1
