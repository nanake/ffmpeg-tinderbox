#!/bin/bash

OPENAPV_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
OPENAPV_COMMIT="2e5996d039f78e213f8f274ff43f69ddf209ce36"

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
    ninja -j"$(nproc)"
    ninja install

    rm -rf "$FFBUILD_PREFIX"/{include/oapv/oapv_exports.h,lib/import}
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    echo --disable-liboapv
}
