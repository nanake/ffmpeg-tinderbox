#!/bin/bash

# https://fftw.org/download.html
FFTW3_SRC="https://fftw.org/fftw-3.3.10.tar.gz"
FFTW3_SHA512="2D34B5CCAC7B08740DBDACC6EBE451D8A34CF9D9BFEC85A5E776E87ADF94ABFD803C222412D8E10FBAA4ED46F504AA87180396AF1B108666CDE4314A55610B40"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    check-wget fftw3.tar.gz "$FFTW3_SRC" "$FFTW3_SHA512"
    tar xaf fftw3.tar.gz
    rm fftw3.tar.gz
    cd fftw*

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTS}=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}
