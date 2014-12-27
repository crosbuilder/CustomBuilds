# install ar to Chromium OS 

DESCRIPTION="Install ar command"
HOMEPAGE="http://pcmemo.take-uma.net/"
SRC_URI="http://192.168.12.14/chromium/ar.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	dobin ar || die
	dolib.so libbfd-2.24.so || die
}
