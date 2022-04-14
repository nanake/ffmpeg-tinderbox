#!/bin/bash

SRT_REPO="https://github.com/Haivision/srt.git"
SRT_COMMIT="fec9a4085c0768c504e0ee575d3d2269e480c8fb"

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
