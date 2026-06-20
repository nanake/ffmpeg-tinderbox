#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="8b4fb6e2562bb86601ea5a2c4140af6d8f3f1cf4"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
    cd libbluray

    git submodule update --init --recursive --depth 1

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Denable_tools=false
        -D{bdj_jar,fontconfig,freetype,libxml2}"=disabled"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    # 💥 symbol collision with FFmpeg
    # since https://github.com/FFmpeg/FFmpeg/commit/c4de577
    export CFLAGS="$CFLAGS -Ddec_init=libbluray_dec_init"

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
