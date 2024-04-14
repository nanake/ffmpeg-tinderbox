#!/bin/bash

# https://git.savannah.gnu.org/gitweb/?p=libiconv.git
LIBICONV_REPO="https://git.savannah.gnu.org/git/libiconv.git"
LIBICONV_COMMIT="17a9a0721831bc747cd2ed6d15a111ed4c7dbcb0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBICONV_REPO" "$LIBICONV_COMMIT" libiconv
    cd libiconv

    ./autopull.sh --one-time

    unset CC CFLAGS

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,dependency-tracking}
        --enable-{static,extra-encodings}
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

    ./autogen.sh
    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
