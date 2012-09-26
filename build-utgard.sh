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


install -d $TARGET_REPO_DIR

# Make sure there is no such directory
rm -rf $COMPILE_DIR/$SRC_DIR_NAME > /dev/null 2>&1

cp -r $SRC_DIR $COMPILE_DIR
cd $COMPILE_DIR/$SRC_DIR_NAME

foreach pkgdir ( *-{git,svn})
	cd $pkgdir
	
	# get rid of debug builds
	rm -rf *.pkg.tar.xz ./src/*-build ./pkg > /dev/null 2>&1

	makepkg -f
	mv *.pkg.tar.xz $TARGET_REPO_DIR 

	rm -rf ./src/*-build ./pkg
	
	cd ..
	
	# sync the current state back to the origin.
	rsync -acv $pkgdir $SRC_DIR
	
	# Get rid of what has been saved.
	rm -rf $pkgdir

	# Need some time to get the CPU temperature down
	sleep $SLEEP_TIME
end

# clean up
rm -rf $COMPILE_DIR/$SRC_DIR_NAME

