#!/bin/bash

LIBFDK_AAC_REPO="https://github.com/mstorsjo/fdk-aac.git"
LIBFDK_AAC_COMMIT="0a90c09e00c3f6238efe8c89daf2c7e55ea4f011"

ffbuild_enabled() {
    [[ $VARIANT == *nonfree* ]] || return -1
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
