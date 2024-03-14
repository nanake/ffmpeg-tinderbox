#!/bin/bash

DVDCSS_REPO="https://github.com/nanake/libdvdcss.git"
DVDCSS_COMMIT="d0b6a291c24eda3727ad5c7a14956fc1fc82446d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DVDCSS_REPO" "$DVDCSS_COMMIT" dvdcss
    cd dvdcss

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,dependency-tracking,doc,maintainer-mode}
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
