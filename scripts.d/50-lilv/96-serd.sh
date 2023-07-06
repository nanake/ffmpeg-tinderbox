#!/bin/bash

SERD_REPO="https://github.com/drobilla/serd.git"
SERD_COMMIT="dbf48d099a78d2075e224549a28e690d56a6d503"

ffbuild_enabled() {
    [[ $TARGET == ucrt64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SERD_REPO" "$SERD_COMMIT" serd
    cd serd

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Dstatic=true
        -D{docs,tests,tools}"=disabled"
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
    ninja -j"$(nproc)"
    ninja install
}
