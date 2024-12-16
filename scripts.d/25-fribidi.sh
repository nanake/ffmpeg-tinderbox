#!/bin/bash

FRIBIDI_REPO="https://github.com/fribidi/fribidi.git"
FRIBIDI_COMMIT="cfc71cda065db859d8b4f1e3c6fe5da7ab02469a"

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
        -Ddefault_library=static
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

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libfribidi
}

ffbuild_unconfigure() {
    echo --disable-libfribidi
}
