#!/bin/bash

SVTAV1_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SVTAV1_COMMIT="8d4a0ae1b85d962d6699a94d6c31a885ee83f375"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SVTAV1_REPO" "$SVTAV1_COMMIT" svtav1
    cd svtav1

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{DEC,SHARED_LIBS,TESTING,APPS}=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    echo --disable-libsvtav1
}
