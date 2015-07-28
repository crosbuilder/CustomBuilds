# install misc helper scripts

DESCRIPTION="Install libffmpeg.so non-propr version "
HOMEPAGE="http://pcmemo.take-uma.net/"
SRC_URI="http://192.168.12.14/chromium/libffmpeg-free.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/chromeos-chrome"
DEPEND=""

src_install() {
	insinto /usr/lib
	doins "${WORKDIR}/libffmpeg.so"

}
