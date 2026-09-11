#!/bin/bash

LIBVPL_REPO="https://github.com/intel/libvpl.git"
LIBVPL_COMMIT="674d015bcb294bc39fa276e99a652ea045423e82"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBVPL_REPO" "$LIBVPL_COMMIT" libvpl
    cd libvpl

    # FIXME: Remove once intel/libvpl#198 landed
    # https://github.com/intel/libvpl/pull/198
    git fetch https://github.com/intel/libvpl.git pull/198/head
    git cherry-pick FETCH_HEAD

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_{EXAMPLES,EXPERIMENTAL,SHARED_LIBS,TESTS}=OFF \
        -DINSTALL_EXAMPLES=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    rm -rf "$FFBUILD_PREFIX"/{etc/vpl,share/vpl}

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/vpl.pc
}

ffbuild_configure() {
    echo --enable-libvpl
}

ffbuild_unconfigure() {
    echo --disable-libvpl
}
