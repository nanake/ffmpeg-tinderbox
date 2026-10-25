#!/bin/bash

XEVE_REPO="https://github.com/mpeg5/xeve.git"
XEVE_COMMIT="fe229fec19e14907c60d65626ebd59f41517d9b3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$XEVE_REPO" xeve
    cd xeve
    git checkout "$XEVE_COMMIT"

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)" xeve
    install -Dm644 src_main/libxeve.a "$FFBUILD_PREFIX/lib/xeve/libxeve.a"
    install -Dm644 xeve.pc "$FFBUILD_PREFIX/lib/pkgconfig/xeve.pc"
    install -Dm644 -t "$FFBUILD_PREFIX/include/xeve/" ../inc/xeve.h xeve_exports.h

    sed -i 's/libdir=.*/&\/xeve/' "$FFBUILD_PREFIX"/lib/pkgconfig/xeve.pc
}

ffbuild_configure() {
    echo --enable-libxeve
}

ffbuild_unconfigure() {
    echo --disable-libxeve
}
