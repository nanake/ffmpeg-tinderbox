#!/bin/bash

SERD_REPO="https://github.com/drobilla/serd.git"
SERD_COMMIT="94e66b9793932483b5b0f5f67a16c4c16bd4665c"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SERD_REPO" "$SERD_COMMIT" serd
    cd serd

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dstatic=true
        -D{docs,tests,tools}"=disabled"
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
    ninja -j"$(nproc)"
    ninja install
}
