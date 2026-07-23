#!/bin/bash

DVDREAD_REPO="https://github.com/nanake/libdvdread.git"
DVDREAD_COMMIT="8e43bfea6cc731f48902ce55e41c540b497b6a84"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DVDREAD_REPO" "$DVDREAD_COMMIT" dvdread
    cd dvdread

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -Denable_docs=false
        -Dlibdvdcss=enabled
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    # 💥 symbol collision with libbluray
    # https://github.com/nanake/libdvdread/commit/408d071
    export CFLAGS="$CFLAGS -Ddir_open_default=libdvdread_dir_open_default -Dfile_open_default=libdvdread_file_open_default"

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libdvdread
}

ffbuild_unconfigure() {
    echo --disable-libdvdread
}
