#!/bin/bash

LIBPSL_REPO="https://github.com/rockdaboot/libpsl.git"
LIBPSL_COMMIT="a629c831d09011f76974d931be7f6167be90673e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBPSL_REPO" "$LIBPSL_COMMIT" libpsl
    cd libpsl

    git submodule update --init --recursive --depth 1

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{docs,tests}"=false"
        -Dbuiltin=true
        -Druntime=no
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
