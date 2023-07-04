#!/bin/bash

SRATOM_REPO="https://github.com/lv2/sratom.git"
SRATOM_COMMIT="b97b447d77fbf172260b4b40f184959f59c3623e"

ffbuild_enabled() {
    [[ $TARGET == ucrt64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SRATOM_REPO" "$SRATOM_COMMIT" sratom
    cd sratom

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
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

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}
