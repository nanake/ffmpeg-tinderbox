#!/bin/bash

ZIMG_REPO="https://bitbucket.org/the-sekrit-twc/zimg.git"
ZIMG_COMMIT="034b7cf5339e576080e61fd53f566387687ff4d6"

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
