#!/bin/bash

LCMS_REPO="https://github.com/mm2/Little-CMS.git"
LCMS_COMMIT="3c18c1ffb0dcff40a67de62eafc3330fbd0bc925"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LCMS_REPO" "$LCMS_COMMIT" lcms
    cd lcms

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{fastfloat,threaded}"=true"
        -Dtests=disabled
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
