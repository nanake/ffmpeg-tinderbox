#!/bin/bash

SRATOM_REPO="https://github.com/lv2/sratom.git"
SRATOM_COMMIT="0713ba20a26c3eb6ae2574b2a23be87ff496f552"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SRATOM_REPO" "$SRATOM_COMMIT" sratom
    cd sratom
    
    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -D{docs,tests}"=disabled"
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
