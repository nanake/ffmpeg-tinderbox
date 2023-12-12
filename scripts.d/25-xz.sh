#!/bin/bash

XZ_REPO="https://github.com/tukaani-project/xz.git"
XZ_COMMIT="d0b24efe6cdc47db5b0fdf6306f70a2e0e63e49e"

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
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DENABLE_THREADS=posix \
        -DCMAKE_USE_PTHREADS_INIT=ON \
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
