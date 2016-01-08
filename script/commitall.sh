#!/bin/bash

cd ~/trunk/src/overlays
git add overlay-x86-generic/make.conf
git commit -m "wifi_bootstrap無効化"
git add overlay-x86-pentiumm
git commit -m "x86-pentiumm追加"

cd ~/trunk/src/platform2
git add crosh
git commit -m "croshカスタムコマンド追加"
git add init/halt/halt.conf
git add init/reboot.conf
git commit -m "シャットダウン・リブート時に任意のコマンドを実行するためのフックを追加"
git add init/preload-network.conf
git commit -m "CF-W2で内蔵ディスクにインストール後にipw2200が使えなくなる問題の対策"
git add installer/chromeos-setdevpasswd
git commit -m "chromeos-setdevpasswdでデフォルトパスワードが消えない問題を修正"
git add installer/chromeos_legacy.cc
git commit -m "内蔵ディスクからのブート時にrootパーティションをPARTITION_UUIDで指定する"
git add login_manager/chrome_setup.cc
git commit -m "Xをroot起動できるようにする"
git add login_manager/init/ui.conf
git commit -m "ハードウェアインスペクションを初回ブート時に実行する"

cd ~/trunk/src/third_party/chromiumos-overlay/
git add chromeos-base/chromeos-chrome/chromeos-chrome-9999.ebuild
git commit -m "chromeカスタマイズ"
git add chromeos-base/chromeos-dev-root
git commit -m "sshd無効化"
git add chromeos-base/crosh/crosh-9999.ebuild
git commit -m "croshカスタムコマンドのインストール処理を追加"
git add chromeos-base/libffmpeg-free/
git commit -m "libffmpeg.soフリーコーデック版パッケージ"
git add chromeos-base/tty
git commit -m "ノーマルモードの時にデベロッパーコンソールを無効にする"
git add chromeos-base/update_engine/files/update-payload-key.pub.pem
git add chromeos-base/update_engine/update_engine-9999.ebuild
git commit -m "アップデートペイロード検証用公開鍵の追加"
git add chromeos/scripts/cros_set_lsb_release
git commit -m "アップデートサーバーのURL追加"
git add eclass/cros-board.eclass
git commit -m "x86-pentiumm BOARDの有効化"
git add profiles/targets/chromeos/package.provided
git commit -m "zipパッケージが無効化されているのを有効にする"
git add sys-libs/gcc-libs/gcc-libs-9999.ebuild
git commit -m "gcc-libsのSSE3以降無効化"
git add virtual/target-chromium-os
git commit -m "各種パッケージをメインebuildに追加"
git add x11-base/xorg-server
git commit -m "VirtualBoxで起動できない問題を修正"

cd ~/trunk/src/third_party/kernel/v3.14/
git add drivers/usb/core/usb.c
git add drivers/usb/host/ehci-hcd.c
git add drivers/usb/host/ehci-pci.c
git commit -m "usbcore.noehciパッチ適用"
git add chromeos/config
git commit -m "カーネルパラメータ変更"
git add drivers/gpu/drm/i915/intel_bios.c
git commit -m "915Gや845GMなどでカーネルパニックになる問題を修正"
git add drivers/gpu/drm/i915/intel_display.c
git commit -m "CF-W2でカーネルパニックになる問題を修正"
git add Documentation/kernel-parameters.txt
git add arch/x86/boot/cpucheck.c
git add arch/x86/kernel/cpu/amd.c
git add arch/x86/kernel/cpu/intel.c
git add include/linux/kernel.h
git add kernel/module.c
git add kernel/panic.c
git commit -m "PAEパッチ適用"

cd ~/trunk/src/third_party/portage-stable/
git add app-misc/ar
git commit -m "arパッケージ追加"
git add app-misc/myscript
git commit -m "myscriptパッケージ追加"

cd ~/trunk/src/scripts
git add bin/cros_make_image_bootable
git commit -m "baseイメージでもブートパラメータにcros_debugがデフォルトで付加されるようにする"
git add build_library/create_legacy_bootloader_templates.sh
git add build_library/create_legacy_bootloader_templates.sh.orig
git commit -m "ブートパラメータにpaeを追加"
git add build_packages
git commit -m "EMERGE_FLAGにemptytreeを追加(今はコメントアウト)"

