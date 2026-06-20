#!/bin/bash

SOFA_REPO="https://github.com/hoene/libmysofa.git"
SOFA_COMMIT="42f3ae68825a4eb2d5593a2308c3483ebbdd8bfe"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SOFA_REPO" "$SOFA_COMMIT" sofa
    cd sofa

    mkdir ffbuild && cd ffbuild

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_STATIC_LIBS=ON \
        -DBUILD_TESTS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libmysofa
}

ffbuild_unconfigure() {
    echo --disable-libmysofa
}
