#!/bin/bash

XEVD_REPO="https://github.com/mpeg5/xevd.git"
XEVD_COMMIT="7966f43a3566a506e9705c504ba27e844be32591"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$XEVD_REPO" xevd
    cd xevd
    git checkout "$XEVD_COMMIT"

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

    rm -f "$FFBUILD_PREFIX"/lib/libxevd.dll.a
    sed -i 's/libdir=.*/&\/xevd/' "$FFBUILD_PREFIX"/lib/pkgconfig/xevd.pc
}

ffbuild_configure() {
    echo --enable-libxevd
}

ffbuild_unconfigure() {
    echo --disable-libxevd
}
