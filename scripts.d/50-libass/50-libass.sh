#!/bin/bash

ASS_REPO="https://github.com/libass/libass.git"
ASS_COMMIT="f9fd3d20dff1cd84b7c74c8ae7f79711ad7736fa"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ASS_REPO" "$ASS_COMMIT" ass
    cd ass

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{checkasm,compare,fuzz,profile,test}"=disabled"
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
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
