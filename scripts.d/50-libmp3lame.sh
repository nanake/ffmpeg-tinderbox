#!/bin/bash

# https://sourceforge.net/projects/lame/files/lame/
LAME_SRC="https://distfiles.macports.org/lame/lame-3.100.tar.gz"
LAME_SHA512="0844B9EADB4AACF8000444621451277DE365041CC1D97B7F7A589DA0B7A23899310AFD4E4D81114B9912AA97832621D20588034715573D417B2923948C08634B"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    check-wget lame.tar.gz "$LAME_SRC" "$LAME_SHA512"
    tar xaf lame.tar.gz
    rm lame.tar.gz
    cd lame*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-{static,nasm}
        --disable-{shared,cpml,frontend,gtktest}
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
    echo --enable-libmp3lame
}

ffbuild_unconfigure() {
    echo --disable-libmp3lame
}
