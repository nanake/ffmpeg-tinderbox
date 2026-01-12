#!/bin/bash

FC_REPO="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
FC_COMMIT="25c40e71443046db4a89160971948ceca1a0046a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FC_REPO" "$FC_COMMIT" fc
    cd fc

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{cache-build,doc,tests,tools}"=disabled"
        -Diconv=enabled
        -Dxml-backend=libxml2
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
    echo --enable-libfontconfig
}

ffbuild_unconfigure() {
    echo --disable-libfontconfig
}
