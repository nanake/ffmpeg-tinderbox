#!/bin/bash

DVDNAV_REPO="https://github.com/nanake/libdvdnav.git"
DVDNAV_COMMIT="310adf98ffeae4977d9f74478bf44d3bc5b99d4f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DVDNAV_REPO" "$DVDNAV_COMMIT" dvdnav
    cd dvdnav

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

ffbuild_configure() {
    echo --enable-libdvdnav
}

ffbuild_unconfigure() {
    echo --disable-libdvdnav
}
