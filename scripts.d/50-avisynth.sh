#!/bin/bash

AVISYNTH_REPO="https://github.com/AviSynth/AviSynthPlus.git"
AVISYNTH_COMMIT="eb3c433031b180e97632ff32c199ccf980416bfc"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$AVISYNTH_REPO" avisynth
    cd avisynth
    git checkout "$AVISYNTH_COMMIT"

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DHEADERS_ONLY=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)" VersionGen
    ninja install
}

ffbuild_configure() {
    echo --enable-avisynth
}

ffbuild_unconfigure() {
    echo --disable-avisynth
}
