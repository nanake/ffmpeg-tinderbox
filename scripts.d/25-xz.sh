#!/bin/bash

XZ_REPO="https://github.com/tukaani-project/xz.git"
XZ_COMMIT="da359c360e986b21cd8d7b888c6a80f56b9d49c7"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XZ_REPO" "$XZ_COMMIT" xz
    cd xz

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_USE_PTHREADS_INIT=ON \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DXZ_{DOC,TOOL_{LZMAINFO,XZ,XZDEC}}=OFF \
        -GNinja \
        ..

    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
