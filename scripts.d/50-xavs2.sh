#!/bin/bash

XAVS2_REPO="https://github.com/nanake/xavs2.git"
XAVS2_COMMIT="0e5b4da6750b236ea2df60d72ee21d0e7fa85e32"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone "$XAVS2_REPO" xavs2
    cd xavs2
    git checkout "$XAVS2_COMMIT"
    cd build/linux

    local myconf=(
        --disable-{avs,cli,ffms,gpac,lavf,lsmash,swscale}
        --enable-{static,pic}
        --extra-asflags="-w-macro-params-legacy"
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-libxavs2
}

ffbuild_unconfigure() {
    echo --disable-libxavs2
}
