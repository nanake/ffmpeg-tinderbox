#!/bin/bash

HEADERS_REPO="https://github.com/KhronosGroup/Vulkan-Headers.git"
HEADERS_COMMIT="v1.4.323"
HEADERS_TAGFILTER="v?.*.*"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$HEADERS_REPO" "$HEADERS_COMMIT" vkheaders
    cd vkheaders

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DVULKAN_HEADERS_ENABLE_INSTALL=YES \
        -DVULKAN_HEADERS_ENABLE_{MODULE,TESTS}=NO \
        -GNinja \
        ..
    ninja install

    cat >"$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc <<EOF
prefix=$FFBUILD_PREFIX
includedir=\${prefix}/include

Name: vulkan
Version: ${HEADERS_COMMIT:1}
Description: Vulkan (Headers Only)
Cflags: -I\${includedir}
EOF
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
