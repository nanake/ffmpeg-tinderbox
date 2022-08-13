#!/bin/bash

RAV1E_SRC_PREFIX="https://github.com/xiph/rav1e/releases/download/p20220802"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    if [[ $TARGET == win64 ]]; then
        wget -O rav1e.zip "${RAV1E_SRC_PREFIX}/rav1e-windows-gnu.zip"
    else
        echo "Unknown target"
        return -1
    fi

    unzip rav1e.zip
    cd rav1e-*

    rm -r bin lib/*.dll.a
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
