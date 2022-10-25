#!/bin/bash

THEORA_SRC="https://github.com/nanake/theora/releases/download/git-718071/theora-git-7180717-mingw-w64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget -O theora.tar.xz "$THEORA_SRC"
    tar xaf theora.tar.xz
    rm theora.tar.xz
    cd theora*

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
    echo --enable-libtheora
}

ffbuild_unconfigure() {
    echo --disable-libtheora
}
