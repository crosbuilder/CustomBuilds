# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that are needed inside the Chromium OS base (release)"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
# Note: Do not utilize USE=internal here.  Update virtual/target-chrome-os instead.
IUSE="
	biod
	bluetooth
	bootchart
	bootimage
	buffet
	cellular
	compupdates
	containers
	cr50_onboard
	+cras
	+crash_reporting
	+cros_disks
	cros_ec
	cros_embedded
	cups
	+debugd
	dptf
	eclog
	feedback
	+fonts
	gobi
	intel_lpe
	kvm_host
	mtd
	+network_time
	nfc
	pam
	peerd
	postscript
	+power_management
	+profile
	+readahead
	scanner
	+shill
	+syslog
	+system_locales
	systemd
	touchview
	+tpm
	-tpm2
	+trim_supported
	+vpn
	watchdog
	wifi_bootstrapping
	wimax
"

REQUIRED_USE="cellular? ( shill )"

################################################################################
#
# READ THIS BEFORE ADDING PACKAGES TO THIS EBUILD!
#
################################################################################
#
# Every chromeos dependency (along with its dependencies) is included in the
# release image -- more packages contribute to longer build times, a larger
# image, slower and bigger auto-updates, increased security risks, etc. Consider
# the following before adding a new package:
#
# 1. Does the package really need to be part of the release image?
#
# Some packages can be included only in the developer or test images, i.e., the
# target-os-dev or chromeos-test ebuilds. If the package will eventually be used
# in the release but it's still under development, consider adding it to
# target-os-dev initially until it's ready for production.
#
# 2. Why is the package a direct dependency of the chromeos ebuild?
#
# It makes sense for some packages to be included as a direct dependency of the
# chromeos ebuild but for most it doesn't. The package should be added as a
# direct dependency of the ebuilds for all packages that actually use it -- in
# time, this ensures correct builds and allows easier cleanup of obsolete
# packages. For example, if a utility will be invoked by the session manager,
# its package should be added as a dependency in the chromeos-login ebuild. If
# the package really needs to be a direct dependency of the chromeos ebuild,
# consider adding a comment why the package is needed and how it's used.
#
# 3. Are all default package features and dependent packages needed?
#
# The release image should include only packages and features that are needed in
# the production system. Often packages pull in features and additional packages
# that are never used. Review these and consider pruning them (e.g., through USE
# flags).
#
# 4. What is the impact on the image size?
#
# Before adding a package, evaluate the impact on the image size. If the package
# and its dependencies increase the image size significantly, consider
# alternative packages or approaches.
#
# 5. Is the package needed on all targets?
#
# If the package is needed only on some target boards, consider making it
# conditional through USE flags in the board overlays.
#
# Variable Naming Convention:
# ---------------------------
# CROS_COMMON_* : Dependencies common to all CrOS flavors
# CROS_E_* : Dependencies for embedded CrOS devices (busybox, etc.)
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, etc.)
################################################################################

################################################################################
#
# Per Package Comments:
# --------------------
# Please add any comments specific to why certain packages are
# pulled into the dependecy here. This is optional and required only when
# the dependency isn't obvious
#
################################################################################

################################################################################
#
# CROS_COMMON_* : Dependencies common to all CrOS flavors (embedded, regular)
#
################################################################################

# Block the old package to force people to clean up.
CROS_COMMON_RDEPEND="!chromeos-base/chromeos"

CROS_COMMON_RDEPEND+="
	syslog? ( app-admin/rsyslog )
	biod? ( chromeos-base/biod )
	bluetooth? ( net-wireless/bluez )
	bootchart? ( app-benchmarks/bootchart )
	tpm? ( chromeos-base/chaps )
	pam? ( virtual/chromeos-auth-config )
	fonts? ( chromeos-base/chromeos-fonts )
	chromeos-base/chromeos-installer
	crash_reporting? ( chromeos-base/crash-reporter )
	cellular? (
		gobi? ( chromeos-base/cromo )
		chromeos-base/mist
	)
	buffet? ( chromeos-base/buffet )
	containers? (
		chromeos-base/container_utils
		chromeos-base/run_oci
	)
	cros_disks? ( chromeos-base/cros-disks )
	debugd? ( chromeos-base/debugd )
	scanner? ( chromeos-base/lorgnette )
	peerd? ( chromeos-base/peerd )
	power_management? ( chromeos-base/power_manager )
	!chromeos-base/platform2
	profile? ( chromeos-base/quipper )
	shill? ( chromeos-base/shill )
	chromeos-base/update_engine
	vpn? ( chromeos-base/vpn-manager )
	wifi_bootstrapping? ( chromeos-base/buffet )
	wimax? ( chromeos-base/wimax_manager )
	cras? ( chromeos-base/audioconfig media-sound/adhd )
	trim_supported? ( chromeos-base/chromeos-trim )
	network_time? ( net-misc/tlsdate )
	nfc? ( net-wireless/neard chromeos-base/neard-configs )
	readahead? ( sys-apps/ureadahead )
	pam? ( sys-auth/pam_pwdfile )
	watchdog? ( sys-apps/daisydog )
	mtd? ( sys-fs/mtd-utils )
	cups? (
		net-print/cups
		postscript? ( net-print/hplip )
	)
	eclog? ( chromeos-base/timberslide )
	chromeos-base/chromeos-machine-id-regen
	sys-kernel/linux-firmware
	virtual/chromeos-bsp
	virtual/chromeos-firewall
	virtual/chromeos-firmware
	virtual/chromeos-interface
	virtual/chromeos-regions
	virtual/implicit-system
	virtual/linux-sources
	virtual/modutils
	virtual/service-manager
	cr50_onboard? ( chromeos-base/chromeos-cr50 )
"
CROS_COMMON_DEPEND="${CROS_COMMON_RDEPEND}
	bootimage? ( sys-boot/chromeos-bootimage )
	cros_ec? ( chromeos-base/chromeos-ec )
"

################################################################################
#
# CROS_* : Dependencies for "regular" CrOS devices (coreutils, X etc)
#
# Comments on individual packages:
# --------------------------------
# app-editors/vim:
# Specifically include the editor we want to appear in chromeos images, so that
# it is deterministic which editor is chosen by 'virtual/editor' dependencies
# (such as in the 'sudo' package).  See crosbug.com/5777.
#
# app-shells/bash:
# We depend on dash for the /bin/sh shell for runtime speeds, but we also
# depend on bash to make the dev mode experience better.  We do not enable
# things like line editing in dash, so its interactive mode is very bare.
#
# sys-apps/which:
# In gentoo, the 'which' command is part of 'system' and certain packages
# assume sys-apps/which is already installed, since we dont install 'system'
# explicitly list sys-apps/which.
#
# app-i18n/nacl-mozc:
# A text input processors based on IME extension APIs.
#
# app-i18n/chinese-input:
# A suite of Chinese input methods based on IME extension APIs.

# app-i18n/keyboard-input:
# A suite of keyboard input methods based on IME extension APIs.
#
# app-i18n/chromeos-hangul
# A Hangul input processor based on extension APIs.
################################################################################

CROS_X86_RDEPEND="
	dptf? ( virtual/dptf )
	intel_lpe? ( virtual/lpe-support )
"
CROS_ARM_RDEPEND="
	chromeos-base/u-boot-scripts
"

CROS_RDEPEND="
	x86? ( ${CROS_X86_RDEPEND} )
	amd64? ( ${CROS_X86_RDEPEND} )
	arm? ( ${CROS_ARM_RDEPEND} )
"

CROS_RDEPEND="${CROS_RDEPEND}
	app-arch/tar
	!tpm2? ( app-crypt/trousers )
	tpm2? ( chromeos-base/trunks )
	app-editors/vim
	app-i18n/chinese-input
	app-i18n/keyboard-input
	app-i18n/japanese-input
	app-i18n/hangul-input
	power_management? ( app-laptop/laptop-mode-tools )
	app-shells/bash
	chromeos-base/common-assets
	chromeos-base/chromeos-imageburner
	kvm_host? (
		net-fs/nfs-ganesha
		sys-kernel/kvmtool
	)
	chromeos-base/crosh
	chromeos-base/crosh-extension
	chromeos-base/dev-install
	compupdates? ( chromeos-base/imageloader )
	chromeos-base/inputcontrol
	chromeos-base/mtpd
	chromeos-base/permission_broker
	system_locales? ( chromeos-base/system-locales )
	chromeos-base/userfeedback
	chromeos-base/vboot_reference
	chromeos-base/vpd
	bluetooth? ( net-wireless/ath3k )
	net-wireless/crda
	net-wireless/marvell_sd8787
	sys-apps/dbus
	sys-apps/flashrom
	sys-apps/iproute2
	sys-apps/mosys
	sys-apps/pv
	sys-apps/rootdev
	!systemd? ( sys-apps/upstart )
	systemd? ( sys-apps/systemd )
	sys-fs/e2fsprogs
	virtual/udev
	touchview? ( chromeos-base/chromeos-accelerometer-init )
	virtual/assets
"

# Build time dependencies
CROS_X86_DEPEND="
	sys-boot/syslinux
"

CROS_DEPEND="${CROS_RDEPEND}
	x86? ( ${CROS_X86_DEPEND} )
	amd64? ( ${CROS_X86_DEPEND} )
"

################################################################################
# CROS_E_* : Dependencies for embedded CrOS devices (busybox, etc.)
#
################################################################################

CROS_E_RDEPEND="${CROS_E_RDEPEND}
	sys-apps/util-linux
	feedback? ( chromeos-base/feedback )
"

# Build time dependencies
CROS_E_DEPEND="${CROS_E_RDEPEND}
"

################################################################################
# Assemble the final RDEPEND and DEPEND variables for portage
################################################################################
RDEPEND="${CROS_COMMON_RDEPEND}
	cros_embedded? ( ${CROS_E_RDEPEND} )
	!cros_embedded? ( ${CROS_RDEPEND} )
"
