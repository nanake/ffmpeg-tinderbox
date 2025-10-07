#!/bin/bash

FFTW_SRC="https://github.com/nanake/fftw3/releases/download/fftw-3.3.10/fftw-3.3.10.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$FFTW_SRC" | tar xz
    cd fftw*

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_TESTS=OFF \
        -DDISABLE_FORTRAN=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}
