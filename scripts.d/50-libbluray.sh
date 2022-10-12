#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="5539addbbf8c26d756fc2cb76b3919f8b73be66a"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
    cd libbluray

    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-static
        --disable-{shared,bdjava-jar,doxygen-{doc,dot,html,pdf,ps},examples}
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
