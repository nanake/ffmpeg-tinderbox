#!/bin/bash

# https://sourceforge.net/projects/opencore-amr/files/opencore-amr/
OAMR_SRC="https://github.com/nanake/opencore-amr/releases/download/v0.1.6/opencore-amr-0.1.6-1-mingw-w64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$OAMR_SRC" | tar xJ
    cd opencore*

    if [[ $TARGET == win64 ]]; then
        cd x86_64*
    elif [[ $TARGET == win32 ]]; then
        cd i686*
    else
        echo "Unknown target"
        return -1
    fi

    cp -r include/. "$FFBUILD_PREFIX"/include/.
    cp -r lib/. "$FFBUILD_PREFIX"/lib/.
}

ffbuild_configure() {
    echo --enable-libopencore-amrnb --enable-libopencore-amrwb
}

ffbuild_unconfigure() {
    echo --disable-libopencore-amrnb --disable-libopencore-amrwb
}
