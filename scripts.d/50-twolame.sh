#!/bin/bash

TWOLAME_SRC="https://github.com/nanake/twolame/releases/download/0.4.0/twolame-0.4.0-mingw-w64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget -O twolame.tar.xz "$TWOLAME_SRC"
    tar xaf twolame.tar.xz
    rm twolame.tar.xz
    cd twolame*

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
    echo --enable-libtwolame
}

ffbuild_unconfigure() {
    echo --disable-libtwolame
}

ffbuild_cflags() {
    echo -DLIBTWOLAME_STATIC
}
