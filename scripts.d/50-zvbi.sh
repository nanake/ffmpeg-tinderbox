#!/bin/bash

ZVBI_REPO="https://github.com/zapping-vbi/zvbi.git"
ZVBI_COMMIT="v0.2.42"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=patches/zvbi,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZVBI_REPO" "$ZVBI_COMMIT" zvbi
    cd zvbi

    for patch in /patches/*.patch; do
        echo "Applying $patch"
        git am < "$patch"
    done

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,bktr,dvb,nls,proxy}
        --enable-static
        --with-pic
        --without-{doxygen,x}
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -C src -j$(nproc)
    make -C src install
    make SUBDIRS=. install
}

ffbuild_configure() {
    echo --enable-libzvbi
}

ffbuild_unconfigure() {
    echo --disable-libzvbi
}
