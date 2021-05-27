#!/bin/bash

VKGLS_WIN32="https://github.com/nanake/Vulkan-Loader/releases/download/v1.2.179/vulkan.glslang.win32.tar.xz"
VKGLS_WIN64="https://github.com/nanake/Vulkan-Loader/releases/download/v1.2.179/vulkan.glslang.win64.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    if [[ $TARGET == win32 ]]; then
        wget -O vkgls.tar.xz "$VKGLS_WIN32"
    elif [[ $TARGET == win64 ]]; then
        wget -O vkgls.tar.xz "$VKGLS_WIN64"
    fi

    tar xaf vkgls.tar.xz
    rm vkgls.tar.xz
    cd vulkan*

    cp -r . "$FFBUILD_PREFIX"

    ln -s "$FFBUILD_PREFIX"/lib/libvulkan-1.a "$FFBUILD_PREFIX"/lib/libvulkan.a
}

ffbuild_configure() {
    echo --enable-vulkan --enable-libglslang
}

ffbuild_unconfigure() {
    echo --disable-vulkan --disable-libglslang
}
