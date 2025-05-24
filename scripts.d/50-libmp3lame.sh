#!/bin/bash

LAME_REPO="https://github.com/nanake/lame.git"
LAME_COMMIT="6e03e89e51b307567bcb07d6c17a13aa3bc85144"


ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LAME_REPO" "$LAME_COMMIT" lame
    cd lame

    autoreconf -fvi -I /usr/share/gettext/m4

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,cpml,decoder,dependency-tracking,frontend,gtktest}
        --enable-{static,nasm}
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -DNDEBUG -Wno-error=incompatible-pointer-types"

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-libmp3lame
}

ffbuild_unconfigure() {
    echo --disable-libmp3lame
}
