#!/bin/bash

XVID_SRC="http://downloads.xvid.org/downloads/xvid_latest.tar.gz"

ffbuild_enabled() {
    [[ $VARIANT != lgpl* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    wget -O xvid.tar.gz "$XVID_SRC"
    tar xaf xvid.tar.gz
    rm xvid.tar.gz
    cd xvid*/trunk/xvidcore/build/generic

    ./bootstrap.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
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

    rm "$FFBUILD_PREFIX"/{bin/libxvidcore.dll,lib/libxvidcore.dll.a}
}

ffbuild_configure() {
    echo --enable-libxvid
}

ffbuild_unconfigure() {
    echo --disable-libxvid
}
