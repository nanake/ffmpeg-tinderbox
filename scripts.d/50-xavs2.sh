#!/bin/bash

XAVS2_SRC="https://github.com/nanake/xavs2/releases/download/git-0e5b4da/xavs2-git-0e5b4da-0-mingw-w64.tar.xz"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$XAVS2_SRC" | tar xJ
    cd xavs2*/x86_64*

    cp -r include/. "$FFBUILD_PREFIX"/include/.
    cp -r lib/. "$FFBUILD_PREFIX"/lib/.
}

ffbuild_configure() {
    echo --enable-libxavs2
}

ffbuild_unconfigure() {
    echo --disable-libxavs2
}
