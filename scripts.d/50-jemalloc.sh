#!/bin/bash

JEMALLOC_REPO="https://github.com/jemalloc/jemalloc.git"
JEMALLOC_COMMIT="36becb1302552c24b7bd59d8f00598e10a2411ea"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$JEMALLOC_REPO" "$JEMALLOC_COMMIT" jemalloc
    cd jemalloc

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-jemalloc-prefix=je_
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -fPIE"
    export CXXFLAGS="$CXXFLAGS -fPIE"

    ./autogen.sh "${myconf[@]}"
    make -j"$(nproc)" build_lib_static
    make install_include install_lib_static install_lib_pc
}

ffbuild_configure() {
    echo --custom-allocator=jemalloc
}
