#!/bin/bash

cd ~/trunk/src/overlays
~/myenv/script/repostart.sh my-overlays
git add overlay-x86-generic/make.conf
git commit -m "wifi_bootstrap無効化"
git add overlay-x86-generic/metadata
git add overlay-x86-generic/profiles/base/parent
git commit -m "freon->xorg 切り替え"
git add overlay-x86-pentiumm
git commit -m "x86-pentiumm追加"

cd ~/trunk/src/platform2
~/myenv/script/repostart.sh my-platform2
git add crosh
git commit -m "croshカスタムコマンド追加"
git add init/upstart/halt/halt.conf
git add init/upstart/reboot.conf
git commit -m "シャットダウン・リブート時に任意のコマンドを実行するためのフックを追加"
git add init/upstart/preload-network.conf
git commit -m "CF-W2で内蔵ディスクにインストール後にipw2200が使えなくなる問題の対策"
git rm init/send-boot-mode.conf
git commit -m "send-boot-mode.confを削除：Atom N280で起動後電源断する問題を修正"
git add init/display_low_battery_alert
git add init/upstart/boot-splash.conf
git commit -m "R59でブートスプラッシュ画面が表示されなくなった件の対策"
git add installer/chromeos-setdevpasswd
git commit -m "chromeos-setdevpasswdでデフォルトパスワードが消えない問題を修正"
git add installer/chromeos_legacy.cc
git commit -m "内蔵ディスクからのブート時にrootパーティションをPARTITION_UUIDで指定する"
git add installer/chromeos-install
git commit -m "インストール先ディスクにブートフラグを付加する"
git add login_manager/chrome_setup.cc
git commit -m "Xをroot起動できるようにする"
git add login_manager/init/ui.conf
git add login_manager/init/scripts/ui-pre-start
git commit -m "ハードウェアインスペクションを初回ブート時に実行する"
git add login_manager/chrome_setup.h
git commit -m "login_manager Xorgコードリストア"
git add libchromeos-ui/chromeos/ui/chromium_command_builder.cc
git add libchromeos-ui/chromeos/ui/chromium_command_builder.h
git add libchromeos-ui/chromeos/ui/chromium_command_builder_unittest.cc
git add libchromeos-ui/chromeos/ui/x_server_runner.cc
git add libchromeos-ui/chromeos/ui/x_server_runner.h
git add libchromeos-ui/chromeos/ui/x_server_runner_unittest.cc
git add libchromeos-ui/libchromeos-ui.gyp
git commit -m "libchromeos-ui Xorgコードリストア"
git add power_manager/common/power_constants.cc
git add power_manager/common/power_constants.h
git add power_manager/optional_prefs/check_active_vt
git add power_manager/optional_prefs/lock_vt_before_suspend
git add power_manager/powerd/daemon.cc
git add power_manager/powerd/daemon.h
git add power_manager/powerd/powerd_setuid_helper.cc
git add power_manager/powerd/powerd_suspend
git add power_manager/powerd/system/input_watcher.cc
git add power_manager/powerd/system/input_watcher.h
git add power_manager/powerd/system/input_watcher_interface.h
git add power_manager/powerd/system/input_watcher_stub.cc
git add power_manager/powerd/system/input_watcher_stub.h
git add power_manager/powerd/policy/input_event_handler.cc
git add power_manager/powerd/policy/input_event_handler.h
git add power_manager/powerd/policy/input_event_handler_unittest.cc
git commit -m "power_manager Xorgコードリストア"

cd ~/trunk/src/third_party/chromiumos-overlay/
~/myenv/script/repostart.sh my-chromiumos-overlay
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
git add sys-kernel/linux-firmware/
git commit -m "デフォルトでインストールされないbrcm/bcm*がインストールされるように修正"
git add media-libs/mesa/mesa-9999.ebuild
git commit -m "vmware用mesa修正"
git add licenses/copyright-attribution/media-libs/mesa
git commit -m "vmwareのライセンスファイルを追加"
git add licenses/LICENSE.libertas-fw
git commit -m "Libertas Firmwareのライセンスファイルを追加"
git add chromeos-base/power_manager/power_manager-9999.ebuild
git commit -m "power_manager Xorgコードリストア"
git add virtual/target-chromium-os-dev/target-chromium-os-dev-1.ebuild
git add virtual/target-chromium-os-test/target-chromium-os-test-1.ebuild
git commit -m "virtual Xorgコードリストア"


cd ~/trunk/src/third_party/kernel/v4.4/
~/myenv/script/repostart.sh mykernel
git add drivers/usb/core/usb.c
git add drivers/usb/host/ehci-hcd.c
git add drivers/usb/host/ehci-pci.c
git commit -m "usbcore.noehciパッチ適用"
git add chromeos/config
git commit -m "カーネルパラメータ変更"
git add drivers/gpu/drm/vmwgfx/vmwgfx_fence.c
git commit -m "vmwgfxのコンパイルが通らない問題を修正"
git add drivers/gpu/drm/i915/intel_opregion.c
git commit -m "VAIO VGN-CR62Bで解像度がおかしくなる問題を修正"

cd ~/trunk/src/third_party/portage-stable/
~/myenv/script/repostart.sh my-portage-stable
git add app-misc/ar
git commit -m "arパッケージ追加"
git add app-misc/myscript
git commit -m "myscriptパッケージ追加"
git add app-arch/p7zip
git commit -m "p7zip追加"
git add net-wireless/ralink-rt2860-firmware/
git commit -m "RT2860 Firmwareパッケージ追加"
git add licenses/libertas-fw
git add net-wireless/libertas-firmware/Manifest
git add net-wireless/libertas-firmware/libertas-firmware-20101019.ebuild
git commit -m "LIBERTAS Firmware パッケージ追加"
git add x11-drivers/xf86-video-vmware
git commit -m "xf86-video-vmware 13.1.0にダウングレード"
git add x11-drivers/xf86-input-vmmouse/xf86-input-vmmouse-13.1.0-r1.ebuild
git commit -m "xf86-input-vmmounse 13.1.0にダウングレード"

cd ~/trunk/src/scripts
~/myenv/script/repostart.sh my-scripts
git add bin/cros_make_image_bootable
git commit -m "baseイメージでもブートパラメータにcros_debugがデフォルトで付加されるようにする"
git add build_library/create_legacy_bootloader_templates.sh
git add build_library/create_legacy_bootloader_templates.sh.orig
git commit -m "ブートパラメータにpaeを追加"
git add build_packages
git commit -m "EMERGE_FLAGにemptytreeを追加(今はコメントアウト)"
git add build_image
git commit -m "生成したイメージにブートフラグを付加する"
git add lib/cros_vm_lib.sh
git commit -m "仮想マシン起動時のcpuのデフォルトをkvm32に変更"
git add build_library/base_image_util.sh
git add build_library/dev_image_util.sh
git commit -m "自分でビルドしたglibcに置換する処理を追加"
git add build_library/test_image_content.sh
git commit -m "ブラックリスト処理を除去"
