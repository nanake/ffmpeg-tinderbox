#!/bin/bash

# https://notabug.org/RiCON/decklink-headers.git
DECKLINK_REPO="https://github.com/nanake/decklink-headers.git"
DECKLINK_COMMIT="23194d695a3ae4aca7bc6c2f16dd6e7325a41c27"

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
