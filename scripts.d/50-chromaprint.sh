#!/bin/bash

CHROMAPRINT_REPO="https://github.com/acoustid/chromaprint.git"
CHROMAPRINT_COMMIT="41a3e8fb3eb907d7a0338ada291982672a2226df"

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
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
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
