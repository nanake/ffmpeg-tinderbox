#!/bin/bash

FREETYPE_REPO="https://gitlab.freedesktop.org/freetype/freetype.git"
FREETYPE_COMMIT="1eb04c71ebd807156681b1fbf52514416a83dcee"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FREETYPE_REPO" "$FREETYPE_COMMIT" freetype
    cd freetype

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
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

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-libfreetype
}

ffbuild_unconfigure() {
    echo --disable-libfreetype
}
