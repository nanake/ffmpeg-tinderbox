#!/bin/bash

GMP_REPO="https://github.com/BtbN/gmplib.git"
GMP_COMMIT="9dff3be5f5bd1f417a81a482bb59f4b25c33cc8a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$GMP_REPO" "$GMP_COMMIT" gmp
    cd gmp

    ./.bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-{static,maintainer-mode}
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
    echo --enable-gmp
}

ffbuild_unconfigure() {
    echo --disable-gmp
}
