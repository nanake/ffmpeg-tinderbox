#!/bin/bash

SVTAV1_REPO="https://gitlab.com/AOMediaCodec/SVT-AV1.git"
SVTAV1_COMMIT="29c1a434f434ad37d7412f0437f3318f32a82f49"

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
        -DBUILD_{APPS,SHARED_LIBS,TESTING}=OFF \
        -DENABLE_AVX512=ON \
        -DSVT_AV1_LTO=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    echo --disable-libsvtav1
}
