#!/bin/bash

LIBXML2_REPO="https://gitlab.gnome.org/GNOME/libxml2.git"
LIBXML2_COMMIT="1d4f5d24ac3976012ab1f5b811385e7b00caaecf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # pinned to last known good
    # build bustage on ubuntu:kinetic (mingw-w64 10.0 AND gcc-10.3)
    if [[ $TARGET == win32 ]]; then
        LIBXML2_COMMIT="6a5c88cc5e009def0b6d9706019d799fce49faa1"
    fi

    git-mini-clone "$LIBXML2_REPO" "$LIBXML2_COMMIT" libxml2
    cd libxml2

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --without-{catalog,debug,docbook,history,html,python}
        --disable-{shared,maintainer-mode}
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
