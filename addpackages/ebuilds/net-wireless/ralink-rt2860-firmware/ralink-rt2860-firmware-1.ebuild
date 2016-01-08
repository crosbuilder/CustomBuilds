# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Firmware for Wireless Ralink RT2860PCI/mPCI/PCIe/CB(RT2760/RT2790/RT2860/RT2890"

HOMEPAGE="http://www.ralinktech.com/ralink/Home/Support/Linux.html"
FW_FILE="ralink-rt2860-firmware.tar.gz"
SRC_URI="http://192.168.12.14/chromium/${FW_FILE}"
# SRC_URI="http://www.ralinktech.com.tw/data/drivers/${FW_FILE}"

LICENSE="LICENCE.ralink-firmware.txt LICENCE.ralink_a_mediatek_company_firmware"
SLOT="0"
KEYWORDS="*"

IUSE=""

src_install() {
	cd ${WORKDIR}/lib/firmware
	insinto /lib/firmware
	doins *.bin
	doins *.txt
}
