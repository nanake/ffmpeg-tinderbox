#!/bin/bash

LIBVA_REPO="https://github.com/intel/libva.git"
LIBVA_COMMIT="181964965d0ab11d5fd680b722d4845fbc89f5a5"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVA_REPO" "$LIBVA_COMMIT" libva
    cd libva

    sed -i "s/shared_library/library/g" va/meson.build

    mkdir mybuild && cd mybuild

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Denable_docs=false
        -Dwith_win32=yes
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
    echo --enable-vaapi
}

ffbuild_unconfigure() {
    echo --disable-vaapi
}
