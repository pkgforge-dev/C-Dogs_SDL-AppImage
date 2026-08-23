#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm cmake gtk3

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini sdl2_image-mini

echo "Building C-Dogs SDL..."
echo "---------------------------------------------------------------"
REPO="https://github.com/cxong/cdogs-sdl"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of C-Dogs SDL..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone --recursive --depth 1 "$REPO" ./cdogs-sdl
else
	echo "Making stable build of C-Dogs SDL..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | grep -oE 'refs/tags/[0-9.]+$' | sed 's|refs/tags/||' | tail -n1)"
	git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./cdogs-sdl
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
sed -i 's/-Winline -Werror/-Winline/' ./cdogs-sdl/CMakeLists.txt
sed -i 's/ -Werror//g' ./cdogs-sdl/src/CMakeLists.txt

# Build SDL2_mixer statically (fixes ogg-vorbis crash)
SDL2_MIXER_VER=2.8.1
curl -L "https://github.com/libsdl-org/SDL_mixer/releases/download/release-${SDL2_MIXER_VER}/SDL2_mixer-${SDL2_MIXER_VER}.tar.gz" | tar xz
cd SDL2_mixer-${SDL2_MIXER_VER}
sed -i 's|/etc/timidity.cfg|/etc/timidity/timidity.cfg|g' src/codecs/music_timidity.c
./configure \
    --enable-music-ogg-stb \
    --enable-music-flac-libflac \
    --enable-music-mp3-mpg123 \
    --disable-music-ogg-vorbis \
    --disable-music-flac-drflac \
    --disable-music-mp3-drmp3 \
    --prefix=/usr
make
cd ..

# Patch cdogs-sdl to use static SDL2_mixer
SDL2_MIXER_PATH="$PWD/SDL2_mixer-${SDL2_MIXER_VER}"
sed -i "s|include_directories(src src/cdogs)|include_directories(src src/cdogs ${SDL2_MIXER_PATH}/include)|" ./cdogs-sdl/CMakeLists.txt
sed -i 's|find_package(SDL2_mixer REQUIRED)||' ./cdogs-sdl/CMakeLists.txt
sed -i "s|SDL2_mixer::SDL2_mixer|${SDL2_MIXER_PATH}/build/.libs/libSDL2_mixer.a|" ./cdogs-sdl/src/cdogs/CMakeLists.txt
sed -i "s|SDL2_mixer::SDL2_mixer|${SDL2_MIXER_PATH}/build/.libs/libSDL2_mixer.a|" ./cdogs-sdl/src/cdogsed/CMakeLists.txt

cmake -S ./cdogs-sdl -B build -DCMAKE_BUILD_TYPE=Release -DCDOGS_DATA_DIR=./
cmake --build build -j$(nproc)
cmake --install build

mv /usr/local/bin/cdogs-sdl ./AppDir/bin
for d in /usr/local/data /usr/local/missions /usr/local/dogfights /usr/local/graphics /usr/local/music /usr/local/sounds; do
	mv -v $d ./AppDir/bin
done
