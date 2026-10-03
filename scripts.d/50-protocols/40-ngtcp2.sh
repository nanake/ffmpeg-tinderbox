#!/bin/bash

NGTCP2_REPO="https://github.com/ngtcp2/ngtcp2.git"
NGTCP2_COMMIT="a4925d70647b75286b28c37be260de3729c2de3d"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$NGTCP2_REPO" "$NGTCP2_COMMIT" ngtcp2
    cd ngtcp2

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_TESTING=OFF \
        -DENABLE_SHARED_LIB=OFF \
        -DENABLE_{LIB_ONLY,OPENSSL,STATIC_LIB}=ON \
        -DHAVE_SSL_SET_QUIC_TLS_CBS=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Cflags.private: -DNGTCP2_STATICLIB" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libngtcp2.pc
}
