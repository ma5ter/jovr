# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Eselect module to manage JetBrain tools default versions"
HOMEPAGE="https://www.jetbrains.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
	>=app-admin/eselect-1.2.3
"

# Since no source archive, set S to FILESDIR
S="${FILESDIR}"

# No source to fetch, install local script only
src_install() {
	# Eselect modules dir
	newdir="/usr/share/eselect/modules"

	# Install the eselect module script from FILESDIR
	# FILESDIR is the 'files/' directory next to the ebuild
	newscript="jetbrains.eselect"

	# Create target directory for eselect modules
	dodir "$newdir"

	# Copy script to the eselect modules directory
	cp "${S}/${newscript}" "${D}${newdir}/${newscript}"
}

pkg_postinst() {
	einfo "jetbrains eselect module installed."
	einfo "Use 'eselect jetbrains help' for usage information."
}
