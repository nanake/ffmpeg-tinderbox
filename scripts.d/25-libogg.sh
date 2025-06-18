#!/bin/bash

OGG_REPO="https://github.com/xiph/ogg.git"
OGG_COMMIT="5e053961effd1db9c0fd2e83f983b20260c8f03f"

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
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DINSTALL_DOCS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}
