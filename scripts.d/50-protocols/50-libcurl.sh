#!/bin/bash

CURL_REPO="https://github.com/curl/curl.git"
CURL_COMMIT="a75c217404a0b97b54b220660892d0fec8e7536e"

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
        -DCMAKE_REQUIRE_FIND_PACKAGE_NGHTTP2=ON \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_{CURL_EXE,EXAMPLES,{LIBCURL,MISC}_DOCS,TESTING}=OFF \
        -DBUILD_STATIC_{CURL,LIBS}=ON \
        -DCURL_{BROTLI,CA_NATIVE,ZSTD}=ON \
        -DCURL_DISABLE_{DICT,FILE,GOPHER,IMAP,IPFS,LDAP,LDAPS,MQTT,POP3,RTSP,SMTP,TELNET,TFTP,WEBSOCKETS}=ON \
        -DCURL_USE_LIBSSH2=OFF \
        -DCURL_USE_PKGCONFIG=ON \
        -DCURL_USE_{LIBPSL,OPENSSL}=ON \
        -DENABLE_CURL_MANUAL=OFF \
        -D{NGHTTP2,OPENSSL}_USE_STATIC_LIBS=ON \
        -DPICKY_COMPILER=OFF \
        -DUSE_LIBIDN2=OFF \
        -DUSE_NGHTTP2=ON \
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
