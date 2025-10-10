#!/bin/bash

LCEVCDEC_REPO="https://github.com/v-novaltd/LCEVCdec.git"
LCEVCDEC_COMMIT="4.0.2"
LCEVCDEC_TAGFILTER="4.0.*"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 $LCEVCDEC_REPO lcevc && cd lcevc
    git checkout $LCEVCDEC_COMMIT

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DVN_SDK_FFMPEG_LIBS_PACKAGE="" \
        -DVN_SDK_SAMPLE_SOURCE=OFF \
        -GNinja \
        ..

    ninja -j"$(nproc)"
    ninja install

    echo "Libs.private: -lstdc++ -lm" >> "$FFBUILD_PREFIX"/lib/pkgconfig/lcevc_dec.pc
}

ffbuild_configure() {
    echo --enable-liblcevc-dec
}

ffbuild_unconfigure() {
    echo --disable-liblcevc-dec
}
