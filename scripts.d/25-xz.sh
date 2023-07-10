#!/bin/bash

XZ_REPO="https://github.com/xz-mirror/xz.git"
XZ_COMMIT="66bdcfa85fef2911cc80f5f30fed3f9610faccb4"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$XZ_REPO" "$XZ_COMMIT" xz
    cd xz

    ./autogen.sh --no-po4a --no-doxygen

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,doc,lzmadec,lzmainfo,nls,scripts,xz,xzdec}
        --enable-static
        --with-pic
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
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
