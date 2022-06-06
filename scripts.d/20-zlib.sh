#!/bin/bash

ZLIB_REPO="https://github.com/madler/zlib.git"
ZLIB_VERSION="1.2.12"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZLIB_REPO" "v$ZLIB_VERSION" zlib
    cd zlib

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --static
    )

    if [[ $TARGET == win* ]]; then
        export CC="${FFBUILD_CROSS_PREFIX}gcc"
        export AR="${FFBUILD_CROSS_PREFIX}ar"
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-zlib
}

ffbuild_unconfigure() {
    echo --disable-zlib
}
