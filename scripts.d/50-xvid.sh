#!/bin/bash

XVID_REPO="https://github.com/m-ab-s/xvid.git"
XVID_COMMIT="4f02ef0c83387cf030b236114c44af10fd9cd661"

ffbuild_enabled() {
    [[ $VARIANT != lgpl* ]] || return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "COPY $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$XVID_REPO" "$XVID_COMMIT" xvid
    cd xvid/xvidcore/build/generic

    ./bootstrap.sh || return -1

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}" || return -1
    make -j$(nproc) || return -1
    make install || return -1

    rm "$FFBUILD_PREFIX"/{bin/libxvidcore.dll,lib/libxvidcore.dll.a}

    cd ../../../..
    rm -rf xvid
}

ffbuild_configure() {
    echo --enable-libxvid
}

ffbuild_unconfigure() {
    echo --disable-libxvid
}
