#!/bin/bash

LIBXML2_REPO="https://gitlab.gnome.org/GNOME/libxml2.git"
LIBXML2_COMMIT="7d4060d252354a8d650a3c50256fe3679a40691d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBXML2_REPO" "$LIBXML2_COMMIT" libxml2
    cd libxml2

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --without-catalog
        --without-debug
        --without-docbook
        --without-history
        --without-html
        --without-python
        --disable-maintainer-mode
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

    ./autogen.sh "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libxml2
}

ffbuild_unconfigure() {
    echo --disable-libxml2
}
