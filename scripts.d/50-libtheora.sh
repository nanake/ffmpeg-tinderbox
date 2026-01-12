#!/bin/bash

THEORA_REPO="https://github.com/xiph/theora.git"
THEORA_COMMIT="edfba372beb02ff70a1e2797d8cf561c242d0e0b"

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

    # https://gitlab.xiph.org/xiph/theora/-/issues/2343
    # https://code.ffmpeg.org/FFmpeg/FFmpeg/issues/20185
    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --disable-asm
        )
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
