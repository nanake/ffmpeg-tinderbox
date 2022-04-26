#!/bin/bash

BROTLI_REPO="https://github.com/google/brotli.git"
BROTLI_COMMIT="f4153a09f87cbb9c826d8fc12c74642bb2d879ea"

ffbuild_enabled() {
    [[ $ADDINS_STR == *5.0* ]] && return -1
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

    # Build system is severely lacking in options, clean up after it
    rm -r "${FFBUILD_PREFIX}"/bin
    rm "${FFBUILD_PREFIX}"/lib/libbrotli*.dll.a

    mv "${FFBUILD_PREFIX}"/lib/libbrotlienc{-static,}.a
    mv "${FFBUILD_PREFIX}"/lib/libbrotlidec{-static,}.a
    mv "${FFBUILD_PREFIX}"/lib/libbrotlicommon{-static,}.a
}
