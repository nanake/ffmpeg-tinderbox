#!/bin/bash

WEBP_REPO="https://github.com/webmproject/libwebp.git"
WEBP_COMMIT="a582b53b747fd940634deffa175af8b490c578e0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$WEBP_REPO" "$WEBP_COMMIT" webp
    cd webp

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DWEBP_BUILD_{{C,D,GIF2,IMG2,V}WEBP,ANIM_UTILS,EXTRAS,WEBPINFO,WEBPMUX}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libwebp
}

ffbuild_unconfigure() {
    echo --disable-libwebp
}
