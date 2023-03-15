#!/bin/bash

LIBXML2_REPO="https://gitlab.gnome.org/GNOME/libxml2.git"
LIBXML2_COMMIT="b167c7314497b6cb0d9a587a31874ae0d273ffaa"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXML2_REPO" "$LIBXML2_COMMIT" libxml2
    cd libxml2

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DLIBXML2_WITH_{CATALOG,DEBUG,HTML,HTTP,ICONV,LZMA,PROGRAMS,PYTHON,TESTS,ZLIB}=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    sed -i "s|^prefix=.*|prefix=${FFBUILD_PREFIX}|" "$FFBUILD_PREFIX"/lib/pkgconfig/libxml-2.0.pc
}

ffbuild_configure() {
    echo --enable-libxml2
}

ffbuild_unconfigure() {
    echo --disable-libxml2
}
