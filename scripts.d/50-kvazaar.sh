#!/bin/bash

KVAZAAR_REPO="https://github.com/ultravideo/kvazaar.git"
KVAZAAR_COMMIT="b0ed0f97680776214ea668aad9e57978d1433e0e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$KVAZAAR_REPO" "$KVAZAAR_COMMIT" kvazaar
    cd kvazaar

    mkdir kvzbuild && cd kvzbuild

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{KVAZAAR_BINARY,SHARED_LIBS,TESTS}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Cflags.private: -DKVZ_STATIC_LIB" >> "$FFBUILD_PREFIX"/lib/pkgconfig/kvazaar.pc
}

ffbuild_configure() {
    echo --enable-libkvazaar
}

ffbuild_unconfigure() {
    echo --disable-libkvazaar
}
