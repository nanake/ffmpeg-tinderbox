#!/bin/bash

# https://sourceforge.net/projects/opencore-amr/files/opencore-amr/
OAMR_SRC="https://github.com/nanake/opencore-amr/releases/download/v0.1.6/opencore-amr-0.1.6.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$OAMR_SRC" | tar xz
    cd opencore*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,examples}
        --enable-{static,amrnb-encoder,amrnb-decoder}
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

ffbuild_configure() {
    echo --enable-libopencore-amrnb --enable-libopencore-amrwb
}

ffbuild_unconfigure() {
    echo --disable-libopencore-amrnb --disable-libopencore-amrwb
}
