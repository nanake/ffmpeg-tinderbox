#!/bin/bash

AVISYNTH_REPO="https://github.com/AviSynth/AviSynthPlus.git"
AVISYNTH_COMMIT="3a9e2c52c2b3842ca7b8be5c0a521ed2bdb26a59"

ffbuild_enabled() {
    [[ $VARIANT != lgpl* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$AVISYNTH_REPO" "$AVISYNTH_COMMIT" avisynth
    cd avisynth

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DHEADERS_ONLY=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-avisynth
}

ffbuild_unconfigure() {
    echo --disable-avisynth
}
