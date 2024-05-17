#!/bin/bash

XEVD_REPO="https://github.com/mpeg5/xevd.git"
XEVD_COMMIT="8e2ed4fa5dca87046773e7b3846b36217cd06463"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$XEVD_REPO" xevd
    cd xevd
    git checkout "$XEVD_COMMIT"

    mkdir build && cd build

    # FIXME: remove once PR merged
    # 💥 symbol collision with xeve
    export CFLAGS="$CFLAGS -Dmc_filter_bilin_horz_sse=xevd_mc_filter_bilin_horz_sse -Dmc_filter_bilin_vert_sse=xevd_mc_filter_bilin_vert_sse"

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    rm -f "$FFBUILD_PREFIX"/lib/libxevd.dll.a
    sed -i 's/libdir=.*/&\/xevd/' "$FFBUILD_PREFIX"/lib/pkgconfig/xevd.pc
}

ffbuild_configure() {
    echo --enable-libxevd
}

ffbuild_unconfigure() {
    echo --disable-libxevd
}
