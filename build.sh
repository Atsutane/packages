#!/usr/bin/env zsh
TARGET_REPO_DIR=/srv/http/repo64

install -d $TARGET_REPO_DIR

foreach pkgdir ( *-{git,svn})

cd $pkgdir
# get rid of debug builds
rm -f *.pkg.tar.xz

makepkg -f
repo-remove `ls $TARGET_REPO_DIR/*.db.tar.gz` $pkgdir
rm -f `ls $TARGET_REPO_DIR/$pkgdir-*.pkg.tar.xz`
mv `ls $pkgdir-*.pkg.tar.xz` $TARGET_REPO_DIR 
repo-add `ls $TARGET_REPO_DIR/*.db.tar.gz` `ls $TARGET_REPO_DIR/$pkgdir-*.pkg.tar.xz`
cd ..

end

