# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/linux-firmware"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Firmware images from the upstream linux-fimware package"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/"

SLOT="0"
KEYWORDS="~*"

IUSE_ATH3K=(
	ath3k-all
	ath3k-ar3011
	ath3k-ar3012
)
IUSE_IWLWIFI=(
	iwlwifi-all
	iwlwifi-100
	iwlwifi-105
	iwlwifi-135
	iwlwifi-1000
	iwlwifi-1000
	iwlwifi-2000
	iwlwifi-2030
	iwlwifi-3160
	iwlwifi-3945
	iwlwifi-4965
	iwlwifi-5000
	iwlwifi-5150
	iwlwifi-6000
	iwlwifi-6005
	iwlwifi-6030
	iwlwifi-6050
	iwlwifi-7260
	iwlwifi-7265
	iwlwifi-7265D
)
IUSE_BRCMWIFI=(
	brcmfmac-all
	brcmfmac4354-sdio
	brcmfmac4356-pcie
	brcmfmac4371-pcie
)
IUSE_LINUX_FIRMWARE=(
	adsp_apl
	adsp_kbl
	adsp_skl
	ath9k_htc
	ath10k
	bcm4354-bt
	cros-pd
	fw_sst
	fw_sst2
	i915_bxt
	i915_skl
	ibt-hw
	"${IUSE_ATH3K[@]}"
	"${IUSE_IWLWIFI[@]}"
	"${IUSE_BRCMWIFI[@]}"
	rtl8168g-1
	marvell-mwlwifi
	marvell-pcie8897
	marvell-pcie8997
	nvidia-xusb
	rockchip-dptx
	rt2870
)
IUSE="${IUSE_LINUX_FIRMWARE[@]/#/linux_firmware_} video_cards_radeon video_cards_amdgpu"
LICENSE="
	linux_firmware_adsp_apl? ( LICENCE.adsp_sst )
	linux_firmware_adsp_kbl? ( LICENCE.adsp_sst )
	linux_firmware_adsp_skl? ( LICENCE.adsp_sst )
	linux_firmware_ath3k-all? ( LICENCE.atheros_firmware )
	linux_firmware_ath3k-ar3011? ( LICENCE.atheros_firmware )
	linux_firmware_ath3k-ar3012? ( LICENCE.atheros_firmware )
	linux_firmware_ath9k_htc? ( LICENCE.atheros_firmware )
	linux_firmware_ath10k? ( LICENCE.atheros_firmware )
	linux_firmware_bcm4354-bt? ( LICENCE.broadcom_bcm43xx )
	linux_firmware_cros-pd? ( BSD-Google )
	linux_firmware_fw_sst? ( LICENCE.fw_sst )
	linux_firmware_fw_sst2? ( LICENCE.IntcSST2 )
	linux_firmware_i915_bxt? ( LICENSE.i915 )
	linux_firmware_i915_skl? ( LICENSE.i915 )
	linux_firmware_ibt-hw? ( LICENCE.ibt_firmware )
	linux_firmware_marvell-mwlwifi? ( LICENCE.Marvell )
	linux_firmware_marvell-pcie8897? ( LICENCE.Marvell )
	linux_firmware_marvell-pcie8997? ( LICENCE.Marvell )
	linux_firmware_nvidia-xusb? ( LICENCE.nvidia )
	linux_firmware_rockchip-dptx? ( LICENCE.rockchip )
	linux_firmware_rt2870? ( LICENCE.ralink-firmware.txt LICENCE.ralink_a_mediatek_company_firmware )
	$(printf 'linux_firmware_%s? ( LICENCE.iwlwifi_firmware ) ' "${IUSE_IWLWIFI[@]}")
	$(printf 'linux_firmware_%s? ( LICENCE.broadcom_bcm43xx ) ' "${IUSE_BRCMWIFI[@]}")
	linux_firmware_rtl8168g-1? ( LICENCE.rtl_nic )
	video_cards_radeon? ( LICENSE.radeon )
	video_cards_amdgpu? ( LICENSE.amdgpu )
"

RDEPEND="
	linux_firmware_marvell-pcie8897? ( !net-wireless/marvell_sd8787[pcie] )
	linux_firmware_marvell-pcie8997? ( !net-wireless/marvell_sd8787[pcie] )
	linux_firmware_ath3k-all? ( !net-wireless/ath3k )
	linux_firmware_ath3k-ar3011? ( !net-wireless/ath3k )
	linux_firmware_ath3k-ar3012? ( !net-wireless/ath3k )
	linux_firmware_nvidia-xusb? ( !sys-kernel/xhci-firmware )
	linux_firmware_rt2870? ( !net-wireless/realtek-rt2800-firmware )
	!net-wireless/ath6k
	!net-wireless/ath10k
	!net-wireless/iwl1000-ucode
	!net-wireless/iwl2000-ucode
	!net-wireless/iwl2030-ucode
	!net-wireless/iwl3945-ucode
	!net-wireless/iwl4965-ucode
	!net-wireless/iwl5000-ucode
	!net-wireless/iwl6000-ucode
	!net-wireless/iwl6005-ucode
	!net-wireless/iwl6030-ucode
	!net-wireless/iwl6050-ucode
"

RESTRICT="binchecks strip test"

FIRMWARE_INSTALL_ROOT="/lib/firmware"

use_fw() {
	use linux_firmware_$1
}

doins_subdir() {
	# Avoid having this insinto command affecting later doins calls.
	local file
	for file in "${@}"; do
		(
		insinto "${FIRMWARE_INSTALL_ROOT}/${file%/*}"
		doins "${file}"
		)
	done
}

src_install() {
	local x
	insinto "${FIRMWARE_INSTALL_ROOT}"
	use_fw adsp_apl && doins_subdir intel/dsp_fw_bxtn*
	use_fw adsp_kbl && doins_subdir intel/dsp_fw_kbl*
	use_fw adsp_skl && doins_subdir intel/dsp_fw_*
	use_fw ath9k_htc && doins htc_*.fw
	use_fw ath10k && doins_subdir ath10k/QCA6174/hw3.0/*
	use_fw bcm4354-bt && doins_subdir brcm/BCM4354_*.hcd
	use_fw cros-pd && doins_subdir cros-pd/*
	use_fw fw_sst && doins_subdir intel/fw_sst*
	use_fw fw_sst2 && doins_subdir intel/IntcSST2.bin
	use_fw i915_bxt && doins_subdir i915/bxt*
	use_fw i915_skl && doins_subdir i915/skl*
	use_fw ibt-hw && doins_subdir intel/ibt-hw-*.bseq
	use_fw rtl8168g-1 && doins_subdir rtl_nic/rtl8168g-1.fw
	use_fw marvell-mwlwifi && doins_subdir mwlwifi/*.bin
	use_fw marvell-pcie8897 && doins_subdir mrvl/pcie8897_uapsta.bin
	use_fw marvell-pcie8997 && doins_subdir mrvl/pcie{uart,usb}8997_combo_v4.bin
	use_fw nvidia-xusb && doins_subdir nvidia/tegra*/xusb.bin
	use_fw rockchip-dptx && doins_subdir rockchip/dptx.bin
	use video_cards_radeon && doins_subdir radeon/*
	use video_cards_amdgpu && doins_subdir amdgpu/{carrizo,stoney}*

	# The extra file rt3070.bin is a symlink.
	use_fw rt2870 && doins rt2870.bin rt3070.bin

	# The firmware here is a mess; install specific files by hand.
	if use linux_firmware_ath3k-all || use linux_firmware_ath3k-ar3011; then
		doins ath3k-1.fw
	fi
	if use linux_firmware_ath3k-all || use linux_firmware_ath3k-ar3012; then
		(
		insinto "${FIRMWARE_INSTALL_ROOT}/ar3k"
		doins ar3k/*.dfu
		)
	fi

	# The Intel wireless firmware is mostly standard.
	for x in "${IUSE_IWLWIFI[@]}"; do
		use_fw ${x} || continue
		case ${x} in
		iwlwifi-all)  doins iwlwifi-*.ucode ;;
		iwlwifi-6005) doins iwlwifi-6000g2a-*.ucode ;;
		iwlwifi-6030) doins iwlwifi-6000g2b-*.ucode ;;
		iwlwifi-*)    doins ${x}-*.ucode ;;
		esac
	done

	for x in "${IUSE_BRCMWIFI[@]}"; do
		use_fw ${x} || continue
		case ${x} in
		brcmfmac-all)      doins_subdir brcm/brcmfmac* ;;
		brcmfmac4354-sdio) doins_subdir brcm/brcmfmac4354-sdio.* ;;
		brcmfmac4356-pcie) doins_subdir brcm/brcmfmac4356-pcie.* ;;
		brcmfmac4371-pcie) doins_subdir brcm/brcmfmac4371-pcie.* ;;
		esac
	done
}
