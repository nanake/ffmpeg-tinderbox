#!/bin/bash

X264_REPO="https://code.videolan.org/videolan/x264.git"
X264_COMMIT="570f6c70808287fc78e3f8f5372a095ec6ef7878"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$X264_REPO" "$X264_COMMIT" x264
    cd x264

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{cli,lavf,swscale,win32thread}
        --enable-{static,pic}
    )

    if [[ $TARGET == win* ]]; then
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
    echo --enable-libx264
}

ffbuild_unconfigure() {
    echo --disable-libx264
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
