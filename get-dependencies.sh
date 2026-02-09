#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm libdecor

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
if [ "${DEVEL_RELEASE-}" = 1 ]; then
  make-aur-package cdogs-git
else
  make-aur-package cdogs
fi

# If the application needs to be manually built that has to be done down here
