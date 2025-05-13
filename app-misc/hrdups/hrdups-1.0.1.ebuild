# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the BSD License

EAPI=8

inherit cmake

DESCRIPTION="Utility designed to identify and manage duplicate files within a directory structure"
HOMEPAGE="https://github.com/ma5ter/hrdups"
SRC_URI="https://github.com/ma5ter/hrdups/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"

S="${WORKDIR}/${P}"
