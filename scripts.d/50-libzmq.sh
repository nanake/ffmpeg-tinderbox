#!/bin/bash

ZMQ_REPO="https://github.com/zeromq/libzmq.git"
ZMQ_COMMIT="3e5ce5c1cd75bd93b2ab51d98e0239eb8628b953"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZMQ_REPO" "$ZMQ_COMMIT" zmq
    cd zmq

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,SHARED,TESTS}=OFF \
        -DENABLE_DRAFTS=OFF \
        -DENABLE_INTRINSICS=ON \
        -DPOLLER=epoll \
        -DZMQ_BUILD_TESTS=OFF \
        -DZMQ_HAVE_IPC=OFF \
        -DZMQ_WIN32_WINNT=0x0A00 \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    echo "Cflags.private: -DZMQ_STATIC" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libzmq.pc
}

ffbuild_configure() {
    echo --enable-libzmq
}

ffbuild_unconfigure() {
    echo --disable-libzmq
}
