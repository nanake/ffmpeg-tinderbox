#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="f33a738fd7bb8b5e1148b0a5424778db7342450b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
    cd libbluray

    git submodule update --init --recursive --depth 1

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Denable_tools=false
        -D{bdj_jar,fontconfig,freetype,libxml2}"=disabled"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
