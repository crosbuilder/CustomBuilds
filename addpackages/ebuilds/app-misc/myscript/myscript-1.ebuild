# install misc helper scripts

DESCRIPTION="Install helper scripts"
HOMEPAGE="http://pcmemo.take-uma.net/"
SRC_URI="http://192.168.12.14/chromium/myscript.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	dodir /usr/local/myscript
	cp -R "${S}/" "${D}/" || die "Install failed!"
}
