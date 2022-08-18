#!/bin/bash

# https://notabug.org/RiCON/decklink-headers.git
DECKLINK_REPO="https://github.com/nanake/decklink-headers.git"
DECKLINK_COMMIT="SDK/12.4"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DECKLINK_REPO" "$DECKLINK_COMMIT" decklink
    cd decklink

    make PREFIX="$FFBUILD_PREFIX" install
}

ffbuild_configure() {
    echo --enable-decklink
}

ffbuild_unconfigure() {
    echo --disable-decklink
}
