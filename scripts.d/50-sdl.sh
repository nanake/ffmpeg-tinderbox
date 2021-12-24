#!/bin/bash

SDL_REPO="https://github.com/libsdl-org/SDL.git"
SDL_COMMIT="a1e992b110b9adf3305a5ebb5514f0e970f7911e"

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
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    sed -ri -e 's/\-Wl,\-\-no\-undefined.*//' \
        -e 's/ \-mwindows//g' \
        -e 's/ \-lSDL2main//g' \
        -e 's/ \-Dmain=SDL_main//g' \
        "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
}

ffbuild_configure() {
    echo --enable-sdl2
}

ffbuild_unconfigure() {
    echo --disable-sdl2
}
