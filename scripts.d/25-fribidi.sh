#!/bin/bash

FRIBIDI_REPO="https://github.com/fribidi/fribidi.git"
FRIBIDI_COMMIT="62bbf0d2ec5d94b7197f692733c43a115dcc89ba"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FRIBIDI_REPO" "$FRIBIDI_COMMIT" fribidi
    cd fribidi

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -D{bin,docs,tests}"=false"
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
    echo --enable-libfribidi
}

ffbuild_unconfigure() {
    echo --disable-libfribidi
}
