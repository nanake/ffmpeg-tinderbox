#!/bin/bash

NGHTTP3_REPO="https://github.com/ngtcp2/nghttp3.git"
NGHTTP3_COMMIT="a1a435bf85dc1cf1f18d799ca81d1e75ac27b7a1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$NGHTTP3_REPO" "$NGHTTP3_COMMIT" nghttp3
    cd nghttp3

    git submodule update --init --recursive --depth=1 lib/sfparse

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_TESTING=OFF \
        -DENABLE_SHARED_LIB=OFF \
        -DENABLE_STATIC_LIB=ON \
        -DENABLE_LIB_ONLY=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Cflags.private: -DNGHTTP3_STATICLIB" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libnghttp3.pc
}
