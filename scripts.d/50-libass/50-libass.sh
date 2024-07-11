#!/bin/bash

ASS_REPO="https://github.com/libass/libass.git"
ASS_COMMIT="6e83137cdbaf4006439d526fef902e123129707b"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ASS_REPO" "$ASS_COMMIT" ass
    cd ass

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
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
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
