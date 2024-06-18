#!/bin/bash

RAV1E_SRC_PREFIX="https://github.com/xiph/rav1e/releases/download/p20240612"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    wget -O rav1e.zip "${RAV1E_SRC_PREFIX}/rav1e-windows-gnu-avx2.zip"
    unzip rav1e.zip
    cd rav1e-*

    rm -rf bin lib/*.dll.a
    sed -i "s|^prefix=.*|prefix=${FFBUILD_PREFIX}|" lib/pkgconfig/rav1e.pc

    mkdir -p "$FFBUILD_PREFIX"/{include,lib/pkgconfig}
    cp -r include/. "$FFBUILD_PREFIX"/include/.
    cp -r lib/. "$FFBUILD_PREFIX"/lib/.
}

ffbuild_configure() {
    echo --enable-librav1e
}

ffbuild_unconfigure() {
    echo --disable-librav1e
}
