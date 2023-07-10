#!/bin/bash

HARFBUZZ_REPO="https://github.com/harfbuzz/harfbuzz.git"
HARFBUZZ_COMMIT="997986ab307bb7868b780a3ff608bd608fb9e077"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$HARFBUZZ_REPO" "$HARFBUZZ_COMMIT" harfbuzz
    cd harfbuzz

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{benchmark,cairo,docs,glib,gobject,icu,introspection,tests}"=disabled"
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libharfbuzz
}

ffbuild_unconfigure() {
    echo --disable-libharfbuzz
}
