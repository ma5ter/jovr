# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Toolchain files for arm-none-eabi"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
	arm-none-eabi/gcc
"

# Since no source archive, set S to FILESDIR
S="${FILESDIR}"

src_install() {
	newdir="/usr/arm-none-eabi"
	dodir "$newdir"
	cp "${S}/toolchain.cmake" "${D}${newdir}/toolchain.cmake"
	cp "${S}/toolchain.env.sh" "${D}${newdir}/toolchain.env.sh"
	chmod +x "${D}${newdir}/toolchain.env.sh"
}
