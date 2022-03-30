#!/bin/bash

ZLIB_SRC="https://github.com/madler/zlib/archive/refs/tags/v1.2.12.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget "$ZLIB_SRC" -O zlib.tar.gz
    tar xaf zlib.tar.gz
    rm zlib.tar.gz
    cd zlib*

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
