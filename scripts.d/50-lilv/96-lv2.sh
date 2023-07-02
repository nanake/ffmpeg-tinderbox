#!/bin/bash

LV2_REPO="https://github.com/lv2/lv2.git"
LV2_COMMIT="bb6a2103c7adf3c1339728915d7f1497ee98dcbf"

ffbuild_enabled() {
    [[ $TARGET == ucrt64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LV2_REPO" "$LV2_COMMIT" lv2
    cd lv2

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -D{docs,plugins,tests}"=disabled"
        -Donline_docs=false
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}
