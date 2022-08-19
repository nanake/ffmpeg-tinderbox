#!/bin/bash

BROTLI_REPO="https://github.com/google/brotli.git"
BROTLI_COMMIT="9801a2c5d6c67c467ffad676ac301379bb877fc3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$BROTLI_REPO" "$BROTLI_COMMIT" brotli
    cd brotli

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    rm "${FFBUILD_PREFIX}"/lib/libbrotli*.dll.a

    mv "${FFBUILD_PREFIX}"/lib/libbrotlienc{-static,}.a
    mv "${FFBUILD_PREFIX}"/lib/libbrotlidec{-static,}.a
    mv "${FFBUILD_PREFIX}"/lib/libbrotlicommon{-static,}.a
}
