#!/bin/bash

# http://fftw.org/download.html
FFTW3_SRC="http://fftw.org/fftw-3.3.9.tar.gz"
FFTW3_SHA512="52ebc2a33063a41fd478f6ea2acbf3b511867f736591d273dd57f9dfca5d3e0b0c73157921b3a36f1a7cfd741a8a6bde0fd80de578040ae730ea168b5ba466cf"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT != lgpl* ]] || return -1
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
        ..
    make -j$(nproc)
    make install
}
