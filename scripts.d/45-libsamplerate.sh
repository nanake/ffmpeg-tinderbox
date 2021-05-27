#!/bin/bash

LIBSR_REPO="https://github.com/libsndfile/libsamplerate.git"
LIBSR_COMMIT="b81ed273be04b86855e45483d1f13ae46338c2de"

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

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_{SHARED_LIBS,TESTING}=NO -DLIBSAMPLERATE_EXAMPLES=OFF -DLIBSAMPLERATE_INSTALL=YES ..
    make -j$(nproc)
    make install
}
