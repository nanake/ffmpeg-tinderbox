#!/bin/bash

SCRIPT_SKIP="1"
LCEVCDEC_REPO="https://github.com/v-novaltd/LCEVCdec.git"
LCEVCDEC_COMMIT="4.0.1"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 $LCEVCDEC_REPO lcevc && cd lcevc
    git checkout $LCEVCDEC_COMMIT

    # FIXME
    # there's no a clean static-link. the public headers unconditionally
    # apply __declspec(dllimport) to API symbols, even when linking statically
    sed -i 's/__declspec(dllexport)//; s/__declspec(dllimport)//' src/pipeline/include/LCEVC/pipeline/detail/pipeline_api.h

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

    {
        echo "Libs.private: -lstdc++ -lm"
        echo "Cflags.private: -DVNEnablePipelineAPIExport"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/lcevc_dec.pc
}
