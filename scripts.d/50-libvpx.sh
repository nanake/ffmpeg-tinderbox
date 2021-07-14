#!/bin/bash

LIBVPX_REPO="https://github.com/webmproject/libvpx.git"
LIBVPX_COMMIT="69fc604636f740a57482f3898c2527d29663ee6d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVPX_REPO" "$LIBVPX_COMMIT" libvpx
    cd libvpx

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-{static,pic,vp9-highbitdepth,vp9-postproc}
        --disable-{shared,docs,examples,install-bins,libyuv,postproc,tools,unit-tests,webm-io}
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --target=x86_64-win64-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    elif [[ $TARGET == win32 ]]; then
        myconf+=(
            --target=x86-win32-gcc
        )
        export CROSS="$FFBUILD_CROSS_PREFIX"
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libvpx
}

ffbuild_unconfigure() {
    echo --disable-libvpx
}
