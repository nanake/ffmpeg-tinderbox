#!/bin/bash

# https://git.savannah.gnu.org/gitweb/?p=libiconv.git
LIBICONV_REPO="https://github.com/nanake/libiconv.git"
LIBICONV_COMMIT="b66b2f548166b667a7c48777ded7506a43971b21"

GNULIB_REPO="https://github.com/coreutils/gnulib.git"
GNULIB_COMMIT="6d64a3155318e29dcf072a5c377ea1a8a9bfec62"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$LIBICONV_REPO" libiconv
    cd libiconv
    git checkout "$LIBICONV_COMMIT"

    git-mini-clone "$GNULIB_REPO" "$GNULIB_COMMIT" gnulib

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
