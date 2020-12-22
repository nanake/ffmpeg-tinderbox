#!/bin/bash

LIBFDK_AAC_REPO="https://github.com/mstorsjo/fdk-aac.git"
LIBFDK_AAC_COMMIT="2e64f76d2e246cd01cf87c12c06b300571ea3d3b"

ffbuild_enabled() {
    [[ $ADDINS_STR != *nonfree* ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBFDK_AAC_REPO" "$LIBFDK_AAC_COMMIT" libfdk_aac
    pushd libfdk_aac

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    autoreconf -i || return -1
    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    popd
    rm -rf libfdk_aac
}

ffbuild_configure() {
    echo --enable-libfdk-aac
}

ffbuild_unconfigure() {
    echo --disable-libfdk-aac
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
