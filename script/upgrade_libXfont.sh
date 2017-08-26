#!/bin/bash
myname=$0
cd ${myname%/*}

source ./revisionup_ebuild.sh

# ~/trunk/src/third_party/portage-stableにブランチが無ければ作る
cd ~/trunk/src/third_party/portage-stable
b=`repo branches | grep portage-stable`
if [ -z "$b" ]; then
	echo create branches on portage-stable
	repo start my-portage-stable .
else
	echo branch already exists. skip.
fi

# libXfont 1.4.9 パッケージをダウンロードする。BOARDはx86-genericで固定
echo upgrade libXfont to 1.5.2
cros_portage_upgrade --board=x86-generic --upgrade x11-libs/libXfont-1.5.2 || exit 1
echo done.

