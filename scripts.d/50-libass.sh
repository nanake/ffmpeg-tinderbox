#!/bin/bash

ASS_REPO="https://github.com/libass/libass.git"
ASS_COMMIT="75a3dbac9bd41842a4d00b0d42c9513e2c8aec67"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ASS_REPO" "$ASS_COMMIT" ass
    cd ass

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
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

    # Workaround for symbol collision
    # Regressed by https://github.com/FFmpeg/FFmpeg/commit/18d6c07
    # See also: https://github.com/libass/libass/issues/654
    export CFLAGS="$CFLAGS -Dread_file=libass_read_file"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
