#!/bin/bash

# https://tukaani.org/xz/
XZ_SRC="https://distfiles.macports.org/xz/xz-5.2.5.tar.bz2"
XZ_SHA512="89E25DDF72427EE9608CBF2E9DBC24D592CB67A27F44CCF7D47E4D9405774444E9CFCD02AC4BCB92064860371ED31D3CFBECD5FE063F296EAD607714C0A664A1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    check-wget xz.tar.bz2 "$XZ_SRC" "$XZ_SHA512"
    tar xaf xz.tar.bz2
    rm xz.tar.bz2
    cd xz*

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
