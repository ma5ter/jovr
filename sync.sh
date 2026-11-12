#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s nullglob

SOURCE_DIR="${SOURCE_DIR:-/media/remote/library/WAREZ/JETBRAINS}"
REPO_ROOT="${REPO_ROOT:-/var/db/repos/jetbrains/dev-util}"
DISTFILES="${DISTFILES:-/var/cache/distfiles}"

changes=0

report_result() {
	local status=$?
	trap - EXIT

	if (( changes )); then
		git add .
		git commit -m "upd"
		git push origin
		echo "Changes!"
	else
		echo "No changes."
	fi

	exit "$status"
}
trap report_result EXIT

die() {
	echo "ERROR: $*" >&2
	exit 1
}

# Validate and canonicalize directories.
[[ -d "$SOURCE_DIR" ]] || die "Source directory not found: $SOURCE_DIR"
[[ -d "$REPO_ROOT"  ]] || die "Repository directory not found: $REPO_ROOT"
[[ -d "$DISTFILES"  ]] || die "Distfiles directory not found: $DISTFILES"

SOURCE_DIR="$(cd -- "$SOURCE_DIR" && pwd -P)"
REPO_ROOT="$(cd -- "$REPO_ROOT" && pwd -P)"
DISTFILES="$(cd -- "$DISTFILES" && pwd -P)"


# Ensure that the distribution is linked into Portage's DISTDIR.
# Existing regular files are preserved.
ensure_distfile_link() {
	local source_file="$1"
	local archive_name="$2"
	local target="$DISTFILES/$archive_name"
	local source_real target_real

	source_real="$(readlink -f -- "$source_file")" ||
		die "Cannot resolve source file: $source_file"

	if [[ -L "$target" ]]; then
		target_real="$(readlink -f -- "$target" 2>/dev/null || true)"

		if [[ "$target_real" != "$source_real" ]]; then
			rm -- "$target"
			changes=1

			ln -s -- "$source_file" "$target"
			echo "Updated distfile link: $archive_name"
		fi
	elif [[ ! -e "$target" ]]; then
		ln -s -- "$source_file" "$target"
		changes=1

		echo "Created distfile link: $archive_name"
	fi
}


sync_package() {
	local package="$1"
	local archive_prefix="$2"
	local package_dir="$REPO_ROOT/$package"

	local archive_file filename version
	local ebuild_file archive_name distfile
	local created

	local -A archives=()

	[[ -d "$package_dir" ]] ||
		die "Package directory not found: $package_dir"

	# Collect available source distributions, indexed by version.
	for archive_file in "$SOURCE_DIR"/*.tar.gz; do
		[[ -f "$archive_file" ]] || continue

		filename="${archive_file##*/}"

		if [[ "$filename" =~ ^${archive_prefix}-([0-9]+([.][0-9]+)*)\.tar\.gz$ ]]; then
			version="${BASH_REMATCH[1]}"
			archives["$version"]="$archive_file"
		fi
	done

	# Remove orphaned versioned ebuild symlinks.
	for ebuild_file in "$package_dir/$package"-*.ebuild; do
		[[ -L "$ebuild_file" ]] || continue

		filename="${ebuild_file##*/}"

		[[ "$filename" =~ ^${package}-([0-9]+([.][0-9]+)*)\.ebuild$ ]] ||
			continue

		version="${BASH_REMATCH[1]}"

		# The matching distribution still exists.
		[[ -n "${archives[$version]+present}" ]] && continue

		archive_name="${archive_prefix}-${version}.tar.gz"
		distfile="$DISTFILES/$archive_name"

		rm -- "$ebuild_file"
		changes=1

		echo "Removed orphaned ebuild: $filename"

		# Remove only the corresponding symlink, never a real distfile.
		if [[ -L "$distfile" ]]; then
			rm -- "$distfile"
			changes=1

			echo "Removed orphaned distfile link: $archive_name"
		fi
	done

	# Create ebuilds and distfiles links for available distributions.
	for version in "${!archives[@]}"; do
		archive_file="${archives[$version]}"
		archive_name="${archive_prefix}-${version}.tar.gz"
		filename="${package}-${version}.ebuild"
		ebuild_file="$package_dir/$filename"

		created=0

		if [[ ! -e "$ebuild_file" && ! -L "$ebuild_file" ]]; then
			[[ -f "$package_dir/${package}.base" ]] ||
				die "Base ebuild not found: $package_dir/${package}.base"

			command -v ebuild >/dev/null 2>&1 ||
				die "'ebuild' command not found"

			# Versioned ebuilds point to the package's common base ebuild.
			ln -s "${package}.base" "$ebuild_file"

			changes=1
			created=1

			echo "Created ebuild: $filename"
		fi

		# Make the source distribution available in Portage DISTDIR.
		ensure_distfile_link "$archive_file" "$archive_name"

		# Generate/update Manifest for each newly created ebuild symlink.
		if (( created )); then
			echo "Generating digest: $filename"

			(
				cd -- "$package_dir"
				ebuild "$filename" digest
			)
		fi
	done
}


# Package name -> distribution archive prefix.
sync_package clion	CLion
sync_package idea	idea
sync_package pycharm	pycharm
sync_package rustrover	RustRover

