#!/bin/bash

GLSLANG_REPO="https://github.com/KhronosGroup/glslang.git"
GLSLANG_COMMIT="3074ec94bf5d77f4bae56f137ff074fd99a8d368"

ffbuild_enabled() {
    [[ $ADDINS_STR == *4.4* ]] && return -1
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
        -D{BUILD_{SHARED_LIBS,TESTING},ENABLE_{CTEST,GLSLANG_BINARIES}}=OFF \
        -D{BUILD_EXTERNAL,ENABLE_{HLSL,OPT}}=ON \
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
