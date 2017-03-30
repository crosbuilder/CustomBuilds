# install misc helper scripts

DESCRIPTION="Install helper scripts"
HOMEPAGE="http://chromiumosde.gozaru.jp/"
SRC_URI="http://192.168.12.14/chromium/myscript.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	dodir /usr/local/myscript
	dodir /opt/myscript
	echo "${WORKDIR}/myscript/*"
	echo ${D}
	ls "${WORKDIR}"
	ls "${WORKDIR}/myscript"
	ls "${WORKDIR}/myscript/*"
	cp -R "${WORKDIR}/myscript" "${D}/opt/" || die "Install failed!"
	# radeonfbのBlacklist化は高速化には有効だがデベロッパーコンソールが使えなくなるのでデフォルトではやらない
	#insinto /etc/modprobe.d
	#echo new D:${D}
	#newins "${WORKDIR}/myscript/modprobe.d/fbdev-blacklist.conf" fbdev-blacklist.conf

}
