#!/bin/bash

ZIMG_REPO="https://github.com/sekrit-twc/zimg.git"
ZIMG_COMMIT="b013c7b006e6bee05b7964162f3a00402168e77f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZIMG_REPO" "$ZIMG_COMMIT" zimg
    cd zimg

    git submodule update --init --recursive --depth 1

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,dependency-tracking}
        --enable-static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            PTHREAD_CFLAGS="-pthread"
            PTHREAD_LIBS="-lpthread"
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
    echo --enable-libzimg
}

ffbuild_unconfigure() {
    echo --disable-libzimg
}
