#!/bin/bash

DVDCSS_REPO="https://github.com/nanake/libdvdcss.git"
DVDCSS_COMMIT="7558acb06d8ba6346a3bb6fd668929ff04573946"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DVDCSS_REPO" "$DVDCSS_COMMIT" dvdcss
    cd dvdcss

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Denable_{docs,examples}"=false"
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
