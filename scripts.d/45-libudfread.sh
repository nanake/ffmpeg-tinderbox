#!/bin/bash

LIBUDFREAD_SRC="https://github.com/nanake/libudfread/releases/download/git-b3e6936/libudfread-git-b3e6936-mingw-w64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget -O libudfread.tar.xz "$LIBUDFREAD_SRC"
    tar xaf libudfread.tar.xz
    rm libudfread.tar.xz
    cd libudfread*

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
