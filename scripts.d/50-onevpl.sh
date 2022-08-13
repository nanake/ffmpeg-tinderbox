#!/bin/bash

ONEVPL_REPO="https://github.com/oneapi-src/oneVPL.git"
ONEVPL_COMMIT="2232af4cdb13c0018d965c3b040466ad89b1922b"

ffbuild_enabled() {
    [[ $ADDINS_STR == *5.1* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ONEVPL_REPO" "$ONEVPL_COMMIT" onevpl
    cd onevpl

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_{DEV,DISPATCHER}=ON \
        -DBUILD_{PREVIEW,SHARED_LIBS,TESTS,TOOLS,TOOLS_ONEVPL_EXPERIMENTAL}=OFF \
        -DINSTALL_EXAMPLE_CODE=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    rm -rf "$FFBUILD_PREFIX"/{etc/vpl,share/vpl}
}

ffbuild_configure() {
    echo --enable-libvpl
}

ffbuild_unconfigure() {
    echo --disable-libvpl
}
