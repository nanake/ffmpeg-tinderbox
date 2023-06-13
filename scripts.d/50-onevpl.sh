#!/bin/bash

ONEVPL_REPO="https://github.com/oneapi-src/oneVPL.git"
ONEVPL_COMMIT="e12ace9761bb52786409e830f619916b86e87fc5"

ffbuild_enabled() {
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
