#!/bin/bash

FRIBIDI_REPO="https://github.com/fribidi/fribidi.git"
FRIBIDI_COMMIT="f22593b82b5d1668d1997dbccd10a9c31ffea3b3"

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
