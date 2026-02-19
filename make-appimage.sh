#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/io.github.cxong.cdogs-sdl.png
export DESKTOP=/usr/share/applications/io.github.cxong.cdogs-sdl.desktop
export STARTUPWMCLASS=cdogs-sdl
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun /usr/bin/cdogs-sdl

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage
