#!/bin/bash

OPENJPEG_REPO="https://github.com/uclouvain/openjpeg.git"
OPENJPEG_COMMIT="e0e0c8026a9280afa6c375464dccac12106971f0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENJPEG_REPO" "$OPENJPEG_COMMIT" openjpeg
    cd openjpeg

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,CODEC,TESTING}=OFF \
        -DWITH_ASTYLE=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libopenjpeg
}

ffbuild_unconfigure() {
    echo --disable-libopenjpeg
}
