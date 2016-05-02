# install misc helper scripts

DESCRIPTION="Install libffmpeg.so non-propr version "
HOMEPAGE="http://pcmemo.take-uma.net/"
SRC_URI="
    penm? ( http://192.168.12.14/chromium/libffmpeg-free_x86-pentiumm.tar.gz )"
#	x64c? ( http://192.168.12.14/chromium/libffmpeg-free_amd64-custom.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="penm x64c"

RDEPEND="chromeos-base/chromeos-chrome"
DEPEND=""

src_install() {
	insinto /usr/lib
	doins "${WORKDIR}/libffmpeg.so"

}
