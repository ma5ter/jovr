# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Regenerate the Manifest with correct checksums:
# Download the file manually, place it in the /var/cache/distfiles directory,
# then run ebuild <ebuild-file> digest to regenerate the Manifest with the new checksums.

EAPI=8

SLOT="$PV"
EXE="$PN"
CNAME="Idea"
FNAME="ideaIU-${SLOT}.tar.gz"

DESCRIPTION="JetBrains $CNAME IDE"
HOMEPAGE="https://www.jetbrains.com"
SRC_URI="https://download-cdn.jetbrains.com/idea/${FNAME}"

LICENSE="all-rights-reserved"
KEYWORDS="amd64"
RESTRICT="mirror bindist fetch"

IUSE="-hrdups"

RDEPEND="
	virtual/libcrypt
	>=app-eselect/eselect-jetbrains-0.1
	hrdups? ( >=app-misc/hrdups-1.0.2 )
"

src_unpack() {
    unpack ${FNAME}
    mv "${WORKDIR}/$(ls -1 ${WORKDIR})" "${WORKDIR}/${PF}"
}

src_install() {
    # Create target directory
    dodir "/opt/jetbrains"
    dodir "/usr/share/applications"
    # Copy the extracted files
    cp -ar "${S}" "${D}/opt/jetbrains/${PF}"
    # Create a desktop entry
    echo "[Desktop Entry]
Name=$CNAME $SLOT
Type=Application
Comment=$DESCRIPTION $SLOT
Exec=/opt/jetbrains/${PF}/bin/${EXE}
TryExec=/opt/jetbrains/${PF}/bin/${EXE}
Icon=/opt/jetbrains/${PF}/bin/${EXE}.svg
Categories=Development;IDE;" > "${D}/usr/share/applications/${PF}.desktop"
}

pkg_postinst() {
    if use hrdups; then
        einfo "optimizing install"
        pushd /opt/jetbrains && hrdups -v && popd
    fi
    eselect jetbrains set "$PN" "$SLOT"
    einfo "${PF} installed in /opt/jetbrains/${PF}"
}
