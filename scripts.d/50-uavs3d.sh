#!/bin/bash

UAVS3D_REPO="https://github.com/uavs3/uavs3d.git"
UAVS3D_COMMIT="0133ee4b4bbbef7b88802e7ad019b14b9b852c2b"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone "$UAVS3D_REPO" uavs3d
    cd uavs3d
    git checkout "$UAVS3D_COMMIT"

    mkdir build/linux
    cd build/linux

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCOMPILE_10BIT=ON \
        -GNinja \
        ../..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libuavs3d
}

ffbuild_unconfigure() {
    echo --disable-libuavs3d
}
