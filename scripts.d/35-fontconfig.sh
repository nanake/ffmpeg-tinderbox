#!/bin/bash

FONTCONFIG_SRC="https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.94.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget "$FONTCONFIG_SRC" -O fc.tar.xz
    tar xaf fc.tar.xz
    rm fc.tar.xz
    cd fontconfig*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,docs}
        --enable-{static,iconv,libxml2}
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
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
