#!/bin/bash

DVDCSS_REPO="https://github.com/nanake/libdvdcss.git"
DVDCSS_COMMIT="d5cc8a29324e197533d04a62156bc9a62f35798a"

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
