#!/bin/bash

SDL_REPO="https://github.com/libsdl-org/SDL.git"
SDL_COMMIT="847539afebe1019c2e1320eccfbe2334d30a2bcc"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SDL_REPO" "$SDL_COMMIT" sdl
    cd sdl

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DSDL_SHARED=OFF \
        -DSDL_{STATIC,STATIC_PIC}=ON \
        -DSDL2_DISABLE_SDL2MAIN=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    sed -ri -e 's/\-Wl,\-\-no\-undefined.*//' \
        -e 's/ \-mwindows//g' \
        "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
}

ffbuild_configure() {
    echo --enable-sdl2
}

ffbuild_unconfigure() {
    echo --disable-sdl2
}
