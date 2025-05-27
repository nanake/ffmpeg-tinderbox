#!/bin/bash

LCEVCDEC_REPO="https://github.com/v-novaltd/LCEVCdec.git"
LCEVCDEC_COMMIT="aae588337b9de3a181f363101f319682b8852bd8"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 $LCEVCDEC_REPO lcevc && cd lcevc
    git checkout $LCEVCDEC_COMMIT

    curl -L https://github.com/v-novaltd/LCEVCdec/pull/23.patch | git apply

    sed -i '/#include <string>/a #include <cstdint>' src/api/src/log.h
    sed -i '127s/WIN32/MSVC/' cmake/modules/VNovaSetup.cmake
    sed -i 's/__declspec(dllexport)//; s/__declspec(dllimport)//' include/LCEVC/lcevc.h

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

    rm -rf "$FFBUILD_PREFIX"/lib/objects-Release
    sed -i 's|-lstdc++ -lm -llcevc_dec_api|-llcevc_dec_api -lstdc++ -lm|' "$FFBUILD_PREFIX"/lib/pkgconfig/lcevc_dec.pc
    echo "Cflags.private: -DVNEnablePublicAPIExport" >> "$FFBUILD_PREFIX"/lib/pkgconfig/lcevc_dec.pc
}

ffbuild_configure() {
    echo --enable-liblcevc-dec
}

ffbuild_unconfigure() {
    echo --disable-liblcevc-dec
}
