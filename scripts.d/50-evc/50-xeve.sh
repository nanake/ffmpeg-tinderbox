#!/bin/bash

XEVE_REPO="https://github.com/mpeg5/xeve.git"
XEVE_COMMIT="7b214663da0140f7ee66adefa6357c45070c818c"

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
    ninja -j"$(nproc)"
    ninja install

    rm -f "$FFBUILD_PREFIX"/lib/libxeve.dll.a
    sed -i 's/libdir=.*/&\/xeve/' "$FFBUILD_PREFIX"/lib/pkgconfig/xeve.pc
}

ffbuild_configure() {
    echo --enable-libxeve
}

ffbuild_unconfigure() {
    echo --disable-libxeve
}
