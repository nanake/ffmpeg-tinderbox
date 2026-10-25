#!/bin/bash

OPENAPV_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
OPENAPV_COMMIT="b4ff69856b4c3e8849df431ee3db54fd535f9bf3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=main --single-branch "$OPENAPV_REPO" openapv
    cd openapv
    git checkout "$OPENAPV_COMMIT"

    echo > app/CMakeLists.txt

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTS=OFF \
        -DOAPV_APP_STATIC_BUILD=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)" oapv
    install -Dm644 lib/liboapv.a "$FFBUILD_PREFIX/lib/liboapv.a"
    install -Dm644 oapv.pc "$FFBUILD_PREFIX/lib/pkgconfig/oapv.pc"
    install -Dm644 ../inc/oapv.h "$FFBUILD_PREFIX/include/oapv/oapv.h"
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    echo --disable-liboapv
}
