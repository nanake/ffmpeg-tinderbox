#!/bin/bash

# https://git.savannah.gnu.org/gitweb/?p=libiconv.git
LIBICONV_REPO="https://git.savannah.gnu.org/git/libiconv.git"
LIBICONV_COMMIT="5bddef718d25e6b4f33b9382d58d1251fe91472d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone "$LIBICONV_REPO" libiconv
    cd libiconv
    git checkout "$LIBICONV_COMMIT"

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
