#!/bin/bash

XZ_REPO="https://github.com/xz-mirror/xz.git"
XZ_COMMIT="6a86e81cab202d0a812a7b2e9efacaf70c58ba38"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XZ_REPO" "$XZ_COMMIT" xz
    cd xz

    ./autogen.sh --no-po4a

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,doc,lzmadec,lzmainfo,nls,scripts,xz,xzdec}
        --enable-static
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
    echo --enable-lzma
}

ffbuild_unconfigure() {
    echo --disable-lzma
}
