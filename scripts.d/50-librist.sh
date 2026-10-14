#!/bin/bash

LIBRIST_REPO="https://code.videolan.org/rist/librist.git"
LIBRIST_COMMIT="47ad5513d1aa0adb692d78f635512e7fa123f06e"

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
        -Ddefault_library=static
        -Dhave_mingw_pthreads=true
        -D{built_tools,test}"=false"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-librist
}

ffbuild_unconfigure() {
    echo --disable-librist
}
