#!/bin/bash

FFTW3_SRC="https://github.com/nanake/fftw3/releases/download/fftw-3.3.10/fftw-3.3.10-mingw-w64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$FFTW3_SRC" | tar xJ
    cd fftw*

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
