#!/bin/bash
# x86-xorg board で書き換えるパッケージをオーバレイディレクトリにコピーして修正を加える

pushd . > /dev/null

# libXfontをアップグレードする
cd ~/trunk/src/third_party/portage-stable/
repo start my-portage-stable .
echo upgrade libXfont to 1.5.2
cros_portage_upgrade --board=x86-xorg --upgrade x11-libs/libXfont-1.5.2 || exit 1
echo done.


