#!/bin/bash

VVENC_REPO="https://github.com/fraunhoferhhi/vvenc.git"
VVENC_COMMIT="0f7b70d6191aa4c4f873cb821841dea9c1a0fe6f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VVENC_REPO" "$VVENC_COMMIT" vvenc
    cd vvenc

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DVVENC_ENABLE_{LINK_TIME_OPT,WERROR}=OFF \
        -DVVENC_LIBRARY_ONLY=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libvvenc
}

ffbuild_unconfigure() {
    echo --disable-libvvenc
}
