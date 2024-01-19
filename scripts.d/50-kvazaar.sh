#!/bin/bash

KVAZAAR_REPO="https://github.com/ultravideo/kvazaar.git"
KVAZAAR_COMMIT="c3380d5b27d5439570ff6c4b6e4ea535a568ee05"

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
        -DBUILD_SHARED_LIBS=OFF \
        -D{BUILD_TESTS,KVZ_BUILD_SHARED_LIBS}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    mv "$FFBUILD_PREFIX"/{share,lib}/pkgconfig/kvazaar.pc
    echo "Cflags.private: -DKVZ_STATIC_LIB" >> "$FFBUILD_PREFIX"/lib/pkgconfig/kvazaar.pc
}

ffbuild_configure() {
    echo --enable-libkvazaar
}

ffbuild_unconfigure() {
    echo --disable-libkvazaar
}
