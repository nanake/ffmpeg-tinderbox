#!/bin/bash

LIBPSL_REPO="https://github.com/rockdaboot/libpsl.git"
LIBPSL_COMMIT="88331dae18f1824ab033f7e77880cf65814fc21a"

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
