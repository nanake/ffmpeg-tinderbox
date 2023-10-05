#!/bin/bash

GME_REPO="https://github.com/libgme/game-music-emu.git"
GME_COMMIT="0521df9f7c0005acc860a27316bbc70706e747c7"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$GME_REPO" gme
    cd gme
    git checkout "$GME_COMMIT"

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_UBSAN=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libgme
}

ffbuild_unconfigure() {
    echo --disable-libgme
}
