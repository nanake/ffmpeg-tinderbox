#!/bin/bash

RUBBERBAND_REPO="https://github.com/breakfastquay/rubberband.git"
RUBBERBAND_COMMIT="e4296ac80b1170018a110bc326fd0d45a0eb27d6"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$RUBBERBAND_REPO" "$RUBBERBAND_COMMIT" rubberband
    cd rubberband

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Dauto_features=disabled
        -Ddefault_library=static
        -Dfft=fftw
        -Dresampler=libsamplerate
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
    echo --enable-librubberband
}

ffbuild_unconfigure() {
    echo --disable-librubberband
}
