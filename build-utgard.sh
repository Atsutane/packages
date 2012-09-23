#!/usr/bin/env zsh
COMPILE_DIR=$HOME/compile
TARGET_REPO_DIR=$COMPILE_DIR/results
SRC_DIR=`pwd`
SRC_DIR_NAME=`pwd | sed -r s-^/.+/--`

install -d $TARGET_REPO_DIR

# Make sure there is no such directory
rm -rf $COMPILE_DIR/$SRC_DIR_NAME

cp -r $SRC_DIR $COMPILE_DIR
cd $COMPILE_DIR/$SRC_DIR_NAME

foreach pkgdir ( *-{git,svn})
	cd $pkgdir
	
	# get rid of debug builds
	rm -rf *.pkg.tar.xz ./src/*-build ./pkg

	makepkg -f
	mv *.pkg.tar.xz $TARGET_REPO_DIR  

	rm -rf ./src/*-build ./pkg
	
	cd ..
	
	# sync the current state back to the origin.
	rsync -acv $pkgdir $SRC_DIR
end

# clean up
rm -rf $COMPILE_DIR/$SRC_DIR_NAME
