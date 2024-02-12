#!/bin/bash

ZVBI_REPO="https://github.com/zapping-vbi/zvbi.git"
ZVBI_COMMIT="b4cef506bbaa7b8bffb07a5566328c7766dbab42"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZVBI_REPO" "$ZVBI_COMMIT" zvbi
    cd zvbi

    # workaround for C type errors in GCC 14
    # GCC 14 turns error on implicit function declarations by default
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=91092
    # this basically restoring the GCC 13 behavior
    export CFLAGS="$CFLAGS -Wno-error=implicit-function-declaration"

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,bktr,dvb,examples,nls,proxy,tests}
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
