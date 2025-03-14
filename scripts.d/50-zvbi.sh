#!/bin/bash

ZVBI_REPO="https://github.com/zapping-vbi/zvbi.git"
ZVBI_COMMIT="5169a428d51c3ae8ff7b0897e8a687d8e05e37b5"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZVBI_REPO" "$ZVBI_COMMIT" zvbi
    cd zvbi

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,bktr,dependency-tracking,dvb,examples,nls,proxy,tests}
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
    make -C src -j"$(nproc)"
    make -C src install
    make SUBDIRS=. install
}

ffbuild_configure() {
    echo --enable-libzvbi
}

ffbuild_unconfigure() {
    echo --disable-libzvbi
}
