#!/bin/bash

XVID_SRC="https://github.com/nanake/xvidcore/releases/download/git-1fd3f3f/xvidcore-git-1fd3f3f-mingw-w64.tar.xz"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    if [[ $TARGET == ucrt64 ]]; then
      XVID_SRC="https://github.com/nanake/xvidcore/releases/download/git-1fd3f3f/xvidcore-git-1fd3f3f-ucrt-mingw-w64.tar.xz"
    fi

    curl -L "$XVID_SRC" | tar xJ
    cd xvid*

    if [[ $TARGET =~ ^(ucrt64|win64)$ ]]; then
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
    echo --enable-libxvid
}

ffbuild_unconfigure() {
    echo --disable-libxvid
}
