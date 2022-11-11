#!/bin/bash

LIBBLURAY_REPO="https://code.videolan.org/videolan/libbluray.git"
LIBBLURAY_COMMIT="c923cc09c274934452f795aa06d3a5aadb31d6fb"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBBLURAY_REPO" "$LIBBLURAY_COMMIT" libbluray
    cd libbluray

    if [[ $TARGET == win32 ]]; then
        sed -i 's/\[snprintf\],, \[AC_MSG_ERROR/\[snprintf\],, \[AC_MSG_WARN/g' configure.ac
    fi

    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-static
        --disable-{shared,bdjava-jar,doxygen-{doc,dot,html,pdf,ps},examples}
        --without-{fontconfig,libxml2}
        --with-pic
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
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libbluray
}

ffbuild_unconfigure() {
    echo --disable-libbluray
}
