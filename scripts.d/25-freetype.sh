#!/bin/bash

FREETYPE_SRC="https://download.savannah.gnu.org/releases/freetype/freetype-2.11.0.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    wget -O ft.tar.xz "$FREETYPE_SRC"
    tar xaf ft.tar.xz
    rm ft.tar.xz
    cd freetype*

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -D{brotli,bzip2,harfbuzz,png,tests,zlib}"=disabled"
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
    echo --enable-libfreetype
}

ffbuild_unconfigure() {
    echo --disable-libfreetype
}
