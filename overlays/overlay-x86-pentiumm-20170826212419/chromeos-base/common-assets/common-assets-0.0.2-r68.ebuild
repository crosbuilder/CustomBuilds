# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="07f5d5eb201c6f5c978df8f86e9e81907df54db1"
CROS_WORKON_TREE="a8c6cae968220f47e3de429415b98a1092329c1d"
CROS_WORKON_PROJECT="chromiumos/platform/assets"

inherit cros-workon toolchain-funcs

DESCRIPTION="Common Chromium OS assets (images, sounds, etc.)"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="+fonts"

DEPEND=""

RDEPEND="!<chromeos-base/chromeos-assets-0.0.2"

# display_boot_message calls the pango-view program.
RDEPEND+="
	fonts? ( chromeos-base/chromeos-fonts )
	x11-libs/pango"

REAL_CURSOR_NAMES="
	fleur
	hand2
	left_ptr
	sb_h_double_arrow
	sb_v_double_arrow
	top_left_corner
	top_right_corner
	xterm"

# These are cursors for which there is no file, but we want to use
# one of the existing files.  So we link them.  The first one is an
# X holdover from some mozilla bug, and without it, we will use the
# default left_ptr_watch bitmap.
LINK_CURSORS="
	08e8e1c95fe2fc01f976f1e063a24ccd:left_ptr_watch
	X_cursor:left_ptr
	arrow:left_ptr
	based_arrow_down:sb_v_double_arrow
	based_arrow_up:sb_v_double_arrow
	boat:left_ptr
	bogosity:left_ptr
	bottom_left_corner:top_right_corner
	bottom_right_corner:top_left_corner
	bottom_side:sb_v_double_arrow
	bottom_tee:sb_v_double_arrow
	box_spiral:left_ptr
	center_ptr:left_ptr
	circle:left_ptr
	clock:left_ptr
	coffee_mug:left_ptr
	diamond_cross:left_ptr
	dot:left_ptr
	dotbox:left_ptr
	double_arrow:sb_v_double_arrow
	draft_large:left_ptr
	draft_small:left_ptr
	draped_box:left_ptr
	exchange:left_ptr
	gobbler:left_ptr
	gumby:left_ptr
	hand1:hand2
	heart:left_ptr
	icon:left_ptr
	iron_cross:left_ptr
	left_ptr_watch:left_ptr
	left_side:sb_h_double_arrow
	left_tee:sb_h_double_arrow
	leftbutton:left_ptr
	ll_angle:top_right_corner
	lr_angle:top_left_corner
	man:left_ptr
	middlebutton:left_ptr
	mouse:left_ptr
	pencil:left_ptr
	pirate:left_ptr
	plus:left_ptr
	right_ptr:left_ptr
	right_side:sb_h_double_arrow
	right_tee:sb_h_double_arrow
	rightbutton:left_ptr
	rtl_logo:left_ptr
	sailboat:left_ptr
	sb_down_arrow:sb_v_double_arrow
	sb_left_arrow:sb_h_double_arrow
	sb_right_arrow:sb_h_double_arrow
	sb_up_arrow:sb_v_double_arrow
	shuttle:left_ptr
	sizing:top_left_corner
	spider:left_ptr
	spraycan:left_ptr
	star:left_ptr
	target:left_ptr
	tcross:left_ptr
	top_left_arrow:left_ptr
	top_side:sb_v_double_arrow
	top_tee:sb_v_double_arrow
	trek:left_ptr
	ul_angle:top_left_corner
	umbrella:left_ptr
	ur_angle:top_right_corner
	watch:left_ptr"

# Languages for which we preinstall text to speech voice data.
TTS_LANGUAGES="de-DE en-GB en-IN en-US es-ES es-US fr-FR hi-IN id-ID it-IT
	ko-KR nl-NL pt-BR"

CROS_WORKON_LOCALNAME="assets"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins -r "${S}"/images/*

	insinto /usr/share/chromeos-assets/images_100_percent
	doins -r "${S}"/images_100_percent/*

	insinto /usr/share/chromeos-assets/images_200_percent
	doins -r "${S}"/images_200_percent/*

	insinto /usr/share/chromeos-assets/text
	doins -r "${S}"/text/boot_messages
	dosbin "${S}"/text/display_boot_message

	insinto /usr/share/chromeos-assets/input_methods
	doins "${S}"/input_methods/*

	mkdir "${S}"/connectivity_diagnostics_launcher_deploy
	pushd "${S}"/connectivity_diagnostics_launcher_deploy > /dev/null
	unpack ./../connectivity_diagnostics_launcher/connectivity_diagnostics_launcher.zip
	insinto /usr/share/chromeos-assets/connectivity_diagnostics_launcher
	doins -r "${S}"/connectivity_diagnostics_launcher_deploy/*
	popd > /dev/null

	mkdir "${S}"/connectivity_diagnostics_deploy
	unzip "${S}"/connectivity_diagnostics/connectivity_diagnostics.zip \
		-d "${S}"/connectivity_diagnostics_deploy
	insinto /usr/share/chromeos-assets/connectivity_diagnostics
	doins -r "${S}"/connectivity_diagnostics_deploy/*

	mkdir "${S}"/connectivity_diagnostics_kiosk_deploy
	unzip "${S}"/connectivity_diagnostics/connectivity_diagnostics_kiosk.zip \
		-d "${S}"/connectivity_diagnostics_kiosk_deploy
	insinto /usr/share/chromeos-assets/connectivity_diagnostics_kiosk
	doins -r "${S}"/connectivity_diagnostics_kiosk_deploy/*

	local CURSOR_DIR="${D}"/usr/share/cursors/xorg-x11/chromeos/cursors

	mkdir -p "${CURSOR_DIR}"
	for i in ${REAL_CURSOR_NAMES}; do
		xcursorgen -p "${S}"/cursors "${S}"/cursors/$i.cfg >"${CURSOR_DIR}/$i"
	done

	for i in ${LINK_CURSORS}; do
		ln -s ${i#*:} "${CURSOR_DIR}/${i%:*}"
	done

	mkdir -p "${D}"/usr/share/cursors/xorg-x11/default
	echo Inherits=chromeos \
		>"${D}"/usr/share/cursors/xorg-x11/default/index.theme

	#
	# Speech synthesis
	#

	insinto /usr/share/chromeos-assets/speech_synthesis/patts

	# Speech synthesis component extension code
	doins "${S}"/speech_synthesis/patts/manifest.json
	doins "${S}"/speech_synthesis/patts/manifest_guest.json
	doins "${S}"/speech_synthesis/patts/tts_main.js
	doins "${S}"/speech_synthesis/patts/tts_controller.js
	doins "${S}"/speech_synthesis/patts/tts_service.nmf

	# Speech synthesis voice data
	for i in ${TTS_LANGUAGES}; do
		doins "${S}"/speech_synthesis/patts/voice_*${i}.js
		doins "${S}"/speech_synthesis/patts/voice_*${i}.zvoice
	done

	# Speech synthesis engine (platform-specific native client module)
	if use arm ; then
		unzip "${S}"/speech_synthesis/patts/tts_service_arm.nexe.zip
		doins "${S}"/tts_service_arm.nexe
	elif use x86 ; then
		unzip "${S}"/speech_synthesis/patts/tts_service_x86-32.nexe.zip
		doins "${S}"/tts_service_x86-32.nexe
	elif use amd64 ; then
		unzip "${S}"/speech_synthesis/patts/tts_service_x86-64.nexe.zip
		doins "${S}"/tts_service_x86-64.nexe
	fi
}
