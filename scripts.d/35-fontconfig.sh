#!/bin/bash

FONTCONFIG_SRC="https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.0.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget "$FONTCONFIG_SRC" -O fc.tar.xz
    tar xaf fc.tar.xz
    rm fc.tar.xz
    cd fontconfig*

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -D{doc,tests,tools}"=disabled"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-fontconfig
}

ffbuild_unconfigure() {
    echo --disable-fontconfig
}
