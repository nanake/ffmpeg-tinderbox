#!/bin/bash

ZSTD_REPO="https://github.com/facebook/zstd.git"
ZSTD_COMMIT="01b7154f1172432f8abe9b3bb9909e14a1176b7d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZSTD_REPO" "$ZSTD_COMMIT" zstd
    cd zstd

    # zstd touches C++ compiler if it is set in toolchain, even for a C-only build
    # https://github.com/facebook/zstd/pull/4810
    sed -i 's/LANGUAGES C /LANGUAGES C CXX /' build/cmake/CMakeLists.txt

    mkdir cmbuild && cd cmbuild

     cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DZSTD_BUILD_{CONTRIB,PROGRAMS,SHARED,TESTS}=OFF \
        -DZSTD_BUILD_STATIC=ON \
        -DZSTD_LEGACY_SUPPORT=OFF \
        -GNinja \
        ../build/cmake
    ninja -j"$(nproc)"
    ninja install
}
