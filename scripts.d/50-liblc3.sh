#!/bin/bash

LC3_REPO="https://github.com/google/liblc3.git"
LC3_COMMIT="efe84d3e0ece9e54591098148da3d10f5503b84e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LC3_REPO" "$LC3_COMMIT" lc3
    cd lc3

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
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
    echo --enable-liblc3
}

ffbuild_unconfigure() {
    echo --disable-liblc3
}
