# install ar to Chromium OS 

DESCRIPTION="Install ar command"
HOMEPAGE="http://pcmemo.take-uma.net/"
SRC_URI="
    penm? ( http://192.168.12.14/chromium/ar_x86-pentiumm.tar.gz )"
#	x64c? ( http://192.168.12.14/chromium/ar_amd64-custom.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="penm x64c"

DEPEND=""
RDEPEND=""

src_install() {
	dobin ar || die
	dolib.so libbfd-2.25.51.20141117.so || die
}
