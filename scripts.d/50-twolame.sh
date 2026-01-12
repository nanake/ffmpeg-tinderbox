#!/bin/bash

TWOLAME_REPO="https://github.com/njh/twolame.git"
TWOLAME_COMMIT="3c7d49d95be71c26afdbaef14def92f3460c7373"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$TWOLAME_REPO" "$TWOLAME_COMMIT" twolame
    cd twolame

    NOCONFIGURE=1 ./autogen.sh
    touch doc/twolame.1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,dependency-tracking,maintainer-mode,sndfile}
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
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
