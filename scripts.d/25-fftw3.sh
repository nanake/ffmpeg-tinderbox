#!/bin/bash

FFTW3_REPO="https://github.com/FFTW/fftw3.git"
FFTW3_COMMIT="9426cd59106ffddde1f55131c07fa9c562fa2f8e"

ffbuild_enabled() {
    # Dependency of GPL-Only librubberband
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FFTW3_REPO" "$FFTW3_COMMIT" fftw3
    cd fftw3

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTS}=OFF \
        -DDISABLE_FORTRAN=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}
