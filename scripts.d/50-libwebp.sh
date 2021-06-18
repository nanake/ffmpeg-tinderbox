#!/bin/bash

WEBP_REPO="https://chromium.googlesource.com/webm/libwebp"
WEBP_COMMIT="f6d2924757f356fcdc620ddaf4c200728a78df09"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$WEBP_REPO" "$WEBP_COMMIT" webp
    cd webp

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-{static,libwebpmux}
        --disable-{shared,gif,gl,jpeg,libwebpextras,libwebpdemux,png,sdl,tiff,wic}
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
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libwebp
}

ffbuild_unconfigure() {
    echo --disable-libwebp
}
