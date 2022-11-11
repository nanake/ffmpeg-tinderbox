#!/bin/bash

LIBSR_SRC="https://github.com/nanake/libsamplerate/releases/download/0.2.2/libsamplerate-0.2.2-mingw-w64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$LIBSR_SRC" | tar xJ
    cd libsamplerate*

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
