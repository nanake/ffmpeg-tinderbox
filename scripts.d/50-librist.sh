#!/bin/bash

LIBRIST_REPO="https://code.videolan.org/rist/librist.git"
# cjson_workaround branch
LIBRIST_COMMIT="099fd39658e3bd37753f38f78221c3134b93f8cf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBRIST_REPO" "$LIBRIST_COMMIT" librist
    cd librist

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Dhave_mingw_pthreads=true
        -D{built_tools,test,use_mbedtls}"=false"
        # Workaround/fixes for cJSON symbol collision
        -Ddisable_json=true
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install

    sed -i -e 's/-lws2_32.*$/-lws2_32 -pthread/' -e 's/Cflags:.*/& -pthread/' "$FFBUILD_PREFIX"/lib/pkgconfig/librist.pc
}

ffbuild_configure() {
    echo --enable-librist
}

ffbuild_unconfigure() {
    echo --disable-librist
}
