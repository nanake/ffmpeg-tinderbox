#!/bin/bash

SRT_REPO="https://github.com/Haivision/srt.git"
SRT_COMMIT="e932e8fbdda4a053023985a6f9c076cf09810e98"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SRT_REPO" "$SRT_COMMIT" srt
    cd srt

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DENABLE_{SHARED,APPS}=OFF \
        -DENABLE_{STATIC,ENCRYPTION}=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libsrt
}

ffbuild_unconfigure() {
    echo --disable-libsrt
}
