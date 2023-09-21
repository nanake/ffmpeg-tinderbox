#!/bin/bash

CHROMAPRINT_REPO="https://github.com/acoustid/chromaprint.git"
CHROMAPRINT_COMMIT="aa67c95b9e486884a6d3ee8b0c91207d8c2b0551"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$CHROMAPRINT_REPO" "$CHROMAPRINT_COMMIT" chromaprint
    cd chromaprint

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTS,TOOLS}=OFF \
        -DFFT_LIB=fftw3 \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    {
        echo "Libs.private: -lfftw3 -lstdc++"
        echo "Cflags.private: -DCHROMAPRINT_NODLL"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/libchromaprint.pc
}

ffbuild_configure() {
    echo --enable-chromaprint
}

ffbuild_unconfigure() {
    echo --disable-chromaprint
}
