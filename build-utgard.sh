#!/usr/bin/env zsh

# This script copies everything to a tmpfs folder and builds VCS packages
# there. This solemnly happens with VCS packages as it does not hurt to build
# stable release packages by hand when a new version has been released.

# default values
COMPILE_DIR=/tmp
SLEEP_TIME=0

source .build.conf > /dev/null 2>&1

TARGET_REPO_DIR=$COMPILE_DIR/results
SRC_DIR=`pwd`
SRC_DIR_NAME=`pwd | sed -r s-^/.+/--`

# Build the given package
build_pkg() {
	local pkgdir="${1}"
	local origin=`pwd`

	cd $pkgdir

	# get rid of debug builds
	rm -rf *.pkg.tar.xz ./src/*-build ./pkg > /dev/null 2>&1

	# build the package
	makepkg -f
	mv *.pkg.tar.xz "$TARGET_REPO_DIR"

	# get rid of unnecessary files
	rm -rf ./src/*-build ./pkg

	cd "$origin"
}

# Prepare the build environment
prepare() {
	install -d "$TARGET_REPO_DIR"

	# Make sure there is no previous directory
	rm -rf "$COMPILE_DIR/$SRC_DIR_NAME" > /dev/null 2>&1
	cp -r "$SRC_DIR" "$COMPILE_DIR"
	cd "$COMPILE_DIR/$SRC_DIR_NAME"
}


prepare

# Have there been packages specified?
pkgs_to_build=()
if [ "$#" -eq 0 ]; then
	pkgs_to_build=(*-{git,svn})
else
	pkgs_to_build=($@)
fi

# Build the packages
foreach pkgdir ($pkgs_to_build)
	build_pkg "$pkgdir"

	# sync the current state back to the origin.
	rsync -acv --delete-before "$pkgdir" "$SRC_DIR"

	# Get rid of what has been saved.
	rm -rf "$pkgdir"

	# Need some time to get the CPU temperature down
	sleep $SLEEP_TIME
end

# clean up
rm -rf "$COMPILE_DIR/$SRC_DIR_NAME"

