#!/bin/bash

BROTLI_REPO="https://github.com/google/brotli.git"
BROTLI_COMMIT="9b83be233e0ec867d91bcd451717c881eaf35ca2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$BROTLI_REPO" "$BROTLI_COMMIT" brotli
    cd brotli

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}
