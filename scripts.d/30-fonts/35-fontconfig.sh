#!/bin/bash

FC_REPO="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
FC_COMMIT="939e33ee473d70a790c89b624385c2c0a5875a51"

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
