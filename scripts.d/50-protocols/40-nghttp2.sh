#!/bin/bash

NGHTTP2_REPO="https://github.com/nghttp2/nghttp2.git"
NGHTTP2_COMMIT="7e10fcf3c58e692902939bab8f898bdd9ec9cff7"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$NGHTTP2_REPO" "$NGHTTP2_COMMIT" nghttp2
    cd nghttp2

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_TESTING=OFF \
        -DENABLE_LIB_ONLY=ON \
        -DENABLE_DOC=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Cflags.private: -DNGHTTP2_STATICLIB" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libnghttp2.pc
}
