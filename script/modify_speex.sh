#!/bin/bash
. ./revisionup_ebuild.sh

cd ~/trunk/src/third_party/chromiumos-overlay/media-libs/speex
target=`find . -name '*.ebuild' -type f -print`
echo ${target}
sed -e '/^IUSE/ s/ sse//' -i ${target}
revisionup_ebuild
