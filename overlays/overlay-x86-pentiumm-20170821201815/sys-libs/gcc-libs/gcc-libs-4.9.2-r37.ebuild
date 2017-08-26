# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.4.3-r3.ebuild,v 1.1 2010/06/19 01:53:09 zorry Exp $

# TODO(toolchain): This should not be building the compiler just to build
# the target libs.  It should re-use the existing system cross compiler.

EAPI="4"

# These are used to find the project sources. Since the gcc-libs sources are
# within the gcc source tree, we leave these "gcc" rather than "gcc-libs".
CROS_WORKON_COMMIT="32c89c19b042a12b5a1bf0153299154ea5435c03"
CROS_WORKON_TREE="63f7c3583b755ddfe5fd77bfa5f448db385fa4e5"
CROS_WORKON_REPO="https://android.googlesource.com"
CROS_WORKON_PROJECT="toolchain/gcc"
CROS_WORKON_LOCALNAME=../aosp/toolchain/gcc
CROS_WORKON_OUTOFTREE_BUILD=1

inherit eutils cros-workon binutils-funcs multilib

DESCRIPTION="The GNU Compiler Collection.  This builds and installs the libgcc, libstdc++, and libgo libraries.  It is board-specific."

LICENSE="GPL-3 LGPL-3 FDL-1.2"
SLOT="0"
KEYWORDS="*"
IUSE="go hardened hardfp mounted_gcc +thumb vtable_verify"
RESTRICT="strip"

: ${CTARGET:=${CHOST}}

update_location_for_aosp() {
	# For aosp gcc repository, the actual gcc directory is 1 more
	# level down, eg. gcc/gcc-4.9, pick up the newest one in this
	# case.
	local gccsub=$(find "${S}" -maxdepth 1 -type d -name "gcc-*" | sort -r | head -1)
	if [[ -d "${gccsub}" ]] && [[ -d "${gccsub}/gcc/config/arm/" ]]; then
		S="${gccsub}"
	fi
	cd "${S}"
}

src_unpack() {
	if use mounted_gcc; then
		if [[ ! -d "$(get_gcc_dir)" ]]; then
			die "gcc dir not mounted/present at: $(get_gcc_dir)"
		fi
	else
		cros-workon_src_unpack
		update_location_for_aosp
	fi

	# Hack around http://crbug.com/284838
	local sb=${SANDBOX_ON}
	export SANDBOX_ON="0"
	touch "${S}"/gcc/config/arm/arm-{tables.opt,tune.md} || die
	export SANDBOX_ON="${sb}"
}

src_configure() {
	if use mounted_gcc && [[ -f $(get_gcc_build_dir)/Makefile ]]; then
		ewarn "Skipping configure due to existing build output"
		return
	fi

	# Unset CC and CXX to let gcc-libs select the right compiler.
	unset CC CXX

	local confgcc=(
		--prefix=/usr
		--bindir=/delete-me
		--datadir=/delete-me
		--includedir=/delete-me
		--with-gxx-include-dir=/delete-me
		--libdir="/usr/$(get_libdir)"
		--with-slibdir="/usr/$(get_libdir)"
		# Disable install of python helpers in the target.
		--without-python-dir

		--build=${CBUILD}
		--host=${CBUILD}
		--target=${CHOST}
		--with-sysroot=/usr/${CTARGET}
		--enable-__cxa_atexit
		--disable-bootstrap
		--enable-checking=release
		--enable-linker-build-id
		--disable-libstdcxx-pch
		--enable-libgomp
		$(use_enable go libatomic)

		# Disable libs we do not care about.
		--disable-libitm
		--disable-libmudflap
		--disable-libquadmath
		--disable-libssp
		--disable-lto
		--disable-multilib
		--disable-openmp
		--disable-libcilkrts
		--with-system-zlib
	)

	GCC_LANG="c,c++"
	use go && GCC_LANG+=",go"
	confgcc+=( --enable-languages=${GCC_LANG} )

	if use vtable_verify; then
		confgcc+=(
			--enable-cxx-flags=-Wl,-L../libsupc++/.libs
			--enable-vtable-verify
		)
	fi

	# Handle target-specific options.
	case ${CTARGET} in
	arm*)	#264534
		local arm_arch="${CTARGET%%-*}"
		# Only do this if arm_arch is armv*
		if [[ ${arm_arch} == armv* ]]; then
			# Convert armv7{a,r,m} to armv7-{a,r,m}
			[[ ${arm_arch} == armv7? ]] && arm_arch=${arm_arch/7/7-}
			# Remove endian ('l' / 'eb')
			[[ ${arm_arch} == *l ]] && arm_arch=${arm_arch%l}
			[[ ${arm_arch} == *eb ]] && arm_arch=${arm_arch%eb}
			confgcc+=(
				--with-arch=${arm_arch}
				--disable-esp
			)
			use hardfp && confgcc+=( --with-float=hard )
			use thumb && confgcc+=( --with-mode=thumb )
		fi
		;;
	i?86*)
		# Hardened is enabled for x86, but disabled for ARM.
		confgcc+=(
			--enable-esp
			--with-arch=atom
			--with-tune=atom
			# Remove this once crash2 supports larger symbols.
			# http://code.google.com/p/chromium-os/issues/detail?id=23321
			--enable-frame-pointer
		)
		;;
	x86_64*-gnux32)
		confgcc+=( --with-abi=x32 --with-multilib-list=mx32 )
		;;
	esac

	# Finally add the user options (if any).
	confgcc+=( ${EXTRA_ECONF} )

	# Build in a separate build tree.
	mkdir -p "$(get_gcc_build_dir)" || die
	cd "$(get_gcc_build_dir)" || die

	# This is necessary because the emerge-${BOARD} machinery sometimes
	# adds machine-specific options to thsee flags that are not
	# appropriate for configuring and building the compiler libraries.
	export CFLAGS='-g -O2 -pipe'
	export CXXFLAGS='-g -O2 -pipe'
	export LDFLAGS="-Wl,-O2 -Wl,--as-needed"

	# and now to do the actual configuration
	addwrite /dev/zero
	echo "Running this:"
	echo "$(get_gcc_dir)"/configure "${confgcc[@]}"
	"$(get_gcc_dir)"/configure "${confgcc[@]}" || die
}

src_compile() {
	cd "$(get_gcc_build_dir)"
	GCC_CFLAGS="${CFLAGS}"
	local target_flags=()
	local target_go_flags=()

	if use hardened; then
		target_flags+=( -fstack-protector-strong -D_FORTIFY_SOURCE=2 )
	fi

	EXTRA_CFLAGS_FOR_TARGET="${target_flags[*]} ${CFLAGS_FOR_TARGET}"
	EXTRA_CXXFLAGS_FOR_TARGET="${target_flags[*]} ${CXXFLAGS_FOR_TARGET}"

	if use vtable_verify; then
		EXTRA_CXXFLAGS_FOR_TARGET+=" -fvtable-verify=std"
	fi

	# libgo on arm must be compiled with -marm. Go's panic/recover functionality
	# is broken in thumb mode.
	if [[ ${CTARGET} == arm* ]]; then
		target_go_flags+=( -marm )
	fi
	EXTRA_GOCFLAGS_FOR_TARGET="${target_go_flags[*]} ${GOCFLAGS_FOR_TARGET}"

	# Do not link libgcc with gold. That is known to fail on internal linker
	# errors. See crosbug.com/16719
	local LD_NON_GOLD="$(get_binutils_path_ld ${CTARGET})/ld"

	# TODO(toolchain): This should not be needed.
	export CHOST="${CBUILD}"

	emake CFLAGS="${GCC_CFLAGS}" \
		LDFLAGS="-Wl,-O1" \
		CFLAGS_FOR_TARGET="$(get_make_var CFLAGS_FOR_TARGET) ${EXTRA_CFLAGS_FOR_TARGET}" \
		CXXFLAGS_FOR_TARGET="$(get_make_var CXXFLAGS_FOR_TARGET) ${EXTRA_CXXFLAGS_FOR_TARGET}" \
		GOCFLAGS_FOR_TARGET="$(get_make_var GOCFLAGS_FOR_TARGET) ${EXTRA_GOCFLAGS_FOR_TARGET}" \
		LD_FOR_TARGET="${LD_NON_GOLD}" \
		all-target
}

src_install() {
	cd "$(get_gcc_build_dir)"
	emake -C "${CTARGET}"/libstdc++-v3/src DESTDIR="${D}" install
	emake -C "${CTARGET}"/libgcc DESTDIR="${D}" install-shared
	if use go; then
		emake -C "${CTARGET}"/libgo DESTDIR="${D}" install
	fi

	# Delete everything we don't care about (headers/etc...).
	rm -rf "${D}"/delete-me "${D}"/usr/$(get_libdir)/gcc/${CTARGET}/
	find "${D}" -name '*.py' -delete

	# Move the libraries to the proper location.  Many target libs do not
	# make this a configure option but hardcode the toolexeclibdir when
	# they're being cross-compiled.
	dolib.so "${D}"/usr/${CTARGET}/$(get_libdir)/lib*.so*
	rm -rf "${D}"/usr/${CTARGET}
	env RESTRICT="" CHOST=${CTARGET} prepstrip "${D}"
}

get_gcc_dir() {
	if use mounted_gcc; then
		echo "${GCC_SOURCE_PATH:=/usr/local/toolchain_root/gcc}"
	else
		echo "${S}"
	fi
}

get_gcc_build_dir() {
	if use mounted_gcc; then
		echo "$(get_gcc_dir)-build-${CTARGET}"
	else
		echo "${WORKDIR}/build"
	fi
}

# Grab a variable from the build system (taken from linux-info.eclass)
get_make_var() {
	local var=$1 makefile=${2:-$(get_gcc_build_dir)/Makefile}
	echo -e "e:\\n\\t@echo \$(${var})\\ninclude ${makefile}" | \
		r=${makefile%/*} emake --no-print-directory -s -f - 2>/dev/null
}
