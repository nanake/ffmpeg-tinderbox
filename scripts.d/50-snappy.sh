#!/bin/bash

SNAPPY_REPO="https://github.com/google/snappy.git"
SNAPPY_COMMIT="25e52c58fbf83ee40f4c9284f757f777f691f76f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SNAPPY_REPO" "$SNAPPY_COMMIT" snappy
    cd snappy

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DSNAPPY_BUILD_{BENCHMARKS,TESTS}=OFF \
        -DSNAPPY_REQUIRE_AVX{,2}=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libsnappy
}

ffbuild_unconfigure() {
    echo --disable-libsnappy
}
