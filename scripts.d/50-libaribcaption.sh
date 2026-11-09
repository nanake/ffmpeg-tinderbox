#!/bin/bash

ARIBCAPTION_REPO="https://github.com/xqq/libaribcaption.git"
ARIBCAPTION_COMMIT="c4a0fd12bc37278073478ca14aabe45fc5a1296b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ARIBCAPTION_REPO" "$ARIBCAPTION_COMMIT" aribcaption
    cd aribcaption

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DARIBCC_USE_FREETYPE=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libaribcaption
}

ffbuild_unconfigure() {
    echo --disable-libaribcaption
}
