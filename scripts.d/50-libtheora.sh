#!/bin/bash

THEORA_REPO="https://github.com/xiph/theora.git"
THEORA_COMMIT="b167cb4a3e3e2d3239d71f0ca2cbc25af4f2183c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$THEORA_REPO" "$THEORA_COMMIT" theora
    cd theora

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,doc,dependency-tracking,examples,maintainer-mode,oggtest,spec,vorbistest}
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
    echo --enable-libtheora
}

ffbuild_unconfigure() {
    echo --disable-libtheora
}
