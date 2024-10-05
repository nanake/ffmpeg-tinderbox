#!/bin/bash

# https://git.savannah.gnu.org/gitweb/?p=libiconv.git
LIBICONV_REPO="https://github.com/nanake/libiconv.git"
LIBICONV_COMMIT="eed6782cbb4651876e3c8b27ea53273f230ee8e2"

GNULIB_REPO="https://github.com/coreutils/gnulib.git"
GNULIN_COMMIT="e44763ddcb12fd04ed0290c3eb8c27e959cd98f1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$LIBICONV_REPO" libiconv
    cd libiconv
    git checkout "$LIBICONV_COMMIT"

    git-mini-clone "$GNULIB_REPO" "$GNULIN_COMMIT" gnulib

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
