#!/bin/bash

OGG_REPO="https://github.com/xiph/ogg.git"
OGG_COMMIT="b674b567403d331aa22a87e66444cdad8ae18aa4"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OGG_REPO" "$OGG_COMMIT" ogg
    cd ogg

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -D{BUILD_SHARED_LIBS,INSTALL_DOCS}=OFF \
        ..
    make -j$(nproc)
    make install
}
