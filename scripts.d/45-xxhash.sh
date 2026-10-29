#!/bin/bash

XXHASH_REPO="https://github.com/Cyan4973/xxHash.git"
XXHASH_COMMIT="adae0686f1da7bc11040574312dcb16b379c6235"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XXHASH_REPO" "$XXHASH_COMMIT" xxhash
    cd xxhash

    mkdir cmbuild && cd cmbuild

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_SHARED_LIBS=OFF \
        -DXXHASH_BUILD_XXHSUM=OFF \
        -GNinja \
        ../build/cmake
    ninja -j"$(nproc)"
    ninja install
}
