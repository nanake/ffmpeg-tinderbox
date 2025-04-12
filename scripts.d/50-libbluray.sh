#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="4066744f4f4cf66d58fcb3e320813d788e9017ba"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
    cd libbluray

    git submodule update --init --recursive --depth 1

    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-static
        --disable-{shared,bdjava-jar,dependency-tracking,doxygen-{doc,dot,html,pdf,ps},examples,extra-warnings}
        --without-{external-libudfread,fontconfig,freetype,libxml2}
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

    # 💥 symbol collision with FFmpeg
    # since https://github.com/FFmpeg/FFmpeg/commit/c4de577
    export CFLAGS="$CFLAGS -Ddec_init=libbluray_dec_init"

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
