#!/bin/bash

LIBSR_REPO="https://github.com/libsndfile/libsamplerate.git"
LIBSR_COMMIT="02391651ff8e4d2fbab22dc7daaacc793ab0704a"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT != lgpl* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBSR_REPO" "$LIBSR_COMMIT" libsr
    cd libsr

    mkdir build
    cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTING}=NO \
        -DLIBSAMPLERATE_EXAMPLES=OFF \
        -DLIBSAMPLERATE_INSTALL=YES \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}
