#!/bin/bash

# https://sourceforge.net/p/soxr/code/ci/master/tree/
SOXR_REPO="https://github.com/nanake/libsoxr.git"
SOXR_COMMIT="945b592b70470e29f917f4de89b4281fbbd540c0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SOXR_REPO" "$SOXR_COMMIT" soxr
    cd soxr

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DWITH_OPENMP=OFF \
        -DBUILD_{TESTS,EXAMPLES,SHARED_LIBS}=OFF \
        -DDOC_INSTALL_DIR="$FFBUILD_PREFIX"/share/doc \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libsoxr
}

ffbuild_unconfigure() {
    echo --disable-libsoxr
}
