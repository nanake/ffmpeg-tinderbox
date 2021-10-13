#!/bin/bash

GLSLANG_REPO="https://github.com/KhronosGroup/glslang.git"
GLSLANG_COMMIT="b9ba4c5743997abbc0df858f2458a86d62af6a25"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$GLSLANG_REPO" "$GLSLANG_COMMIT" glslang
    cd glslang

    python3 ./update_glslang_sources.py

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -D{BUILD_SHARED_LIBS,BUILD_TESTING,ENABLE_CTEST,ENABLE_GLSLANG_BINARIES}=OFF \
        -DBUILD_EXTERNAL=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libglslang
}

ffbuild_unconfigure() {
    echo --disable-libglslang
}
