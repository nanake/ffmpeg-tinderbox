#!/bin/bash

# https://sourceforge.net/projects/opencore-amr/files/opencore-amr/
OAMR_SRC="https://distfiles.macports.org/opencore-amr/opencore-amr-0.1.5.tar.gz"
OAMR_SHA512="C324DB9DCAC5A31BFAC633153BC054BFE42D5FF98202C4ADB3C75A3FAE9792F07F60D48CD659ACF106DACD307174A62B2AEEE22A4AF53CAA20D2BFBA46488FAF"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    check-wget opencore.tar.gz "$OAMR_SRC" "$OAMR_SHA512"
    tar xaf opencore.tar.gz
    rm opencore.tar.gz
    cd opencore*

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,examples}
        --enable-{static,amrnb-encoder,amrnb-decoder}
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
    echo --enable-libopencore-amrnb --enable-libopencore-amrwb
}

ffbuild_unconfigure() {
    echo --disable-libopencore-amrnb --disable-libopencore-amrwb
}
