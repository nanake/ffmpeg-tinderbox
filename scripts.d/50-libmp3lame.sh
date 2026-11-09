#!/bin/bash

LAME_REPO="https://github.com/nanake/lame.git"
LAME_COMMIT="b162a17f6116153c2601d6c81322edd667544ee1"


ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LAME_REPO" "$LAME_COMMIT" lame
    cd lame

    autoreconf -fvi

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,cpml,decoder,dependency-tracking,frontend}
        --enable-static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -DNDEBUG"

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
