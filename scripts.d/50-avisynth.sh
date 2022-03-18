#!/bin/bash

AVISYNTH_REPO="https://github.com/AviSynth/AviSynthPlus.git"
AVISYNTH_COMMIT="7290a6f7f803a06ed31e235785d55dc68ab76d55"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
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
    ninja -j$(nproc) VersionGen
    ninja install
}

ffbuild_configure() {
    echo --enable-avisynth
}

ffbuild_unconfigure() {
    echo --disable-avisynth
}
