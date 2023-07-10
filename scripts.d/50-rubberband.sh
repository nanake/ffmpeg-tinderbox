#!/bin/bash

RUBBERBAND_REPO="https://github.com/breakfastquay/rubberband.git"
RUBBERBAND_COMMIT="1eddafd7a7c8b64e377d64ee5e87ead881a32a48"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$RUBBERBAND_REPO" "$RUBBERBAND_COMMIT" rubberband
    cd rubberband

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        -Ddefault_library=static
        -Dfft=fftw
        -Dresampler=libsamplerate
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-librubberband
}

ffbuild_unconfigure() {
    echo --disable-librubberband
}
