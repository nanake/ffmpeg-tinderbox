#!/bin/bash

SVT_JPEG_XS_REPO="https://github.com/OpenVisualCloud/SVT-JPEG-XS.git"
SVT_JPEG_XS_COMMIT="43cc4b409f1a2f6d5ac66910e7d41426ceb6c016"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SVT_JPEG_XS_REPO" "$SVT_JPEG_XS_COMMIT" svtjpegxs
    cd svtjpegxs

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{APPS,SHARED_LIBS,TESTING}=OFF \
        -DCOVERAGE=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libsvtjpegxs
}

ffbuild_unconfigure() {
    echo --disable-libsvtjpegxs
}
