#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/local/share/icons/hicolor/256x256/apps/io.github.cxong.cdogs-sdl.png
export DESKTOP=/usr/local/share/applications/io.github.cxong.cdogs-sdl.desktop
export STARTUPWMCLASS=cdogs-sdl
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun ./AppDir/bin/cdogs-sdl
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage
