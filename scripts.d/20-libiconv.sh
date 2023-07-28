#!/bin/bash

# https://git.savannah.gnu.org/gitweb/?p=libiconv.git
LIBICONV_REPO="https://git.savannah.gnu.org/git/libiconv.git"
LIBICONV_COMMIT="6e2b31f6d66739c5abd850338ea68c6bd2012812"

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
        --disable-shared
        --enable-{static,extra-encodings}
        --with-pic
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./autogen.sh
    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-iconv
}

ffbuild_unconfigure() {
    echo --disable-iconv
}
