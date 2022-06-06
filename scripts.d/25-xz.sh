#!/bin/bash

# https://tukaani.org/xz/
XZ_SRC="https://github.com/nanake/xz/releases/download/v5.2.5/xz-5.2.5.tar.bz2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget -O xz.tar.bz2 "$XZ_SRC"
    tar xaf xz.tar.bz2
    rm xz.tar.bz2
    cd xz*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,doc,lzmadec,lzmainfo,nls,scripts,xz,xzdec}
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
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
