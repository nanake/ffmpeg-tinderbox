#!/bin/bash

FFNVCODEC_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
FFNVCODEC_COMMIT="f2fb9b36d5e08d6211f7cf6377971c0570939e65"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FFNVCODEC_REPO" "$FFNVCODEC_COMMIT" ffnvcodec
    cd ffnvcodec

    make PREFIX="$FFBUILD_PREFIX" install
}

ffbuild_configure() {
    echo --enable-ffnvcodec --enable-cuda-llvm
}

ffbuild_unconfigure() {
    echo --disable-ffnvcodec --disable-cuda-llvm
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
