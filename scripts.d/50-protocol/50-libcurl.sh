#!/bin/bash

CURL_REPO="https://github.com/curl/curl.git"
CURL_COMMIT="7f4cfe13b67c5b876d109fba04a2f18c05ef6922"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$CURL_REPO" "$CURL_COMMIT" curl
    cd curl

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_{CURL_EXE,EXAMPLES,{LIBCURL,MISC}_DOCS,TESTING}=OFF \
        -DBUILD_STATIC_{CURL,LIBS}=ON \
        -DCURL_USE_{LIBPSL,LIBSSH2}=OFF \
        -DCURL_USE_SCHANNEL=ON \
        -DENABLE_CURL_MANUAL=OFF \
        -DHTTP_ONLY=ON \
        -DPICKY_COMPILER=OFF \
        -DUSE_{NGHTTP2,LIBIDN2}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libcurl
}

ffbuild_unconfigure() {
    echo --disable-libcurl
}
