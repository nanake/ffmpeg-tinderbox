#!/bin/bash

OPENH264_REPO="https://github.com/cisco/openh264.git"
OPENH264_COMMIT="0c9a557a9a6f1d267c4d372221669a8ae69ccda0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENH264_REPO" "$OPENH264_COMMIT" openh264
    cd openh264

    local myconf=(
        PREFIX="$FFBUILD_PREFIX"
        BUILDTYPE=Release
        DEBUGSYMBOLS=False
        LIBDIR_NAME=lib
    )

    if [[ $TARGET == win32 ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=i686
        )
    elif [[ $TARGET == win64 ]]; then
        myconf+=(
            OS=mingw_nt
            ARCH=x86_64
        )
    else
        echo "Unknown target"
        return -1
    fi

    make -j"$(nproc)" "${myconf[@]}" install-static
}

ffbuild_configure() {
    echo --enable-libopenh264
}

ffbuild_unconfigure() {
    echo --disable-libopenh264
}
