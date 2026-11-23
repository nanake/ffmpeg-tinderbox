#!/bin/bash

HARFBUZZ_REPO="https://github.com/harfbuzz/harfbuzz.git"
HARFBUZZ_COMMIT="ce0a1235ae7ea7a8e281e2fa91f8237f4526be92"

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
        -Dgdi=enabled
        -D{benchmark,cairo,chafa,docs,glib,gobject,icu,introspection,tests,utilities}"=disabled"
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
    ninja -j"$(nproc)" libs
    meson install --no-rebuild --only-changed
}

ffbuild_configure() {
    echo --enable-libharfbuzz
}

ffbuild_unconfigure() {
    echo --disable-libharfbuzz
}
