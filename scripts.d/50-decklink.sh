#!/bin/bash

# https://notabug.org/RiCON/decklink-headers.git
DECKLINK_REPO="https://github.com/nanake/decklink-headers.git"
DECKLINK_COMMIT="efb287366bd96065b8ab2c1e64978fde807ead08"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$DECKLINK_REPO" "$DECKLINK_COMMIT" decklink
    pushd decklink

    make PREFIX="$FFBUILD_PREFIX" install || return -1

    popd
    rm -rf decklink
}

ffbuild_configure() {
    echo --enable-decklink
}

ffbuild_unconfigure() {
    echo --disable-decklink
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
