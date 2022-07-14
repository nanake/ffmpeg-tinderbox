#!/bin/bash

OPENJPEG_REPO="https://github.com/uclouvain/openjpeg.git"
OPENJPEG_COMMIT="e3f07dcc07c651321ec3b5f540ef698bbe6f1906"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENJPEG_REPO" "$OPENJPEG_COMMIT" openjpeg
    cd openjpeg

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_PKGCONFIG_FILES=ON \
        -DBUILD_{SHARED_LIBS,CODEC,TESTING}=OFF \
        -DWITH_ASTYLE=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libopenjpeg
}

ffbuild_unconfigure() {
    echo --disable-libopenjpeg
}
