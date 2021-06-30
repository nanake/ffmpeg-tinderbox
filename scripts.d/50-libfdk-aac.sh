#!/bin/bash

LIBFDK_AAC_REPO="https://github.com/mstorsjo/fdk-aac.git"
LIBFDK_AAC_COMMIT="801f67f671929311e0c9952c5f92d6e147c7b003"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBFDK_AAC_REPO" "$LIBFDK_AAC_COMMIT" libfdk-aac
    cd libfdk-aac

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libfdk-aac
}

ffbuild_unconfigure() {
    echo --disable-libfdk-aac
}
