#!/bin/bash

PLACEBO_REPO="https://github.com/haasn/libplacebo.git"
PLACEBO_COMMIT="686ed7e80dc711fe2f6af572f1b4f4c259791a25"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$PLACEBO_REPO" "$PLACEBO_COMMIT" placebo
    cd placebo
    git submodule update --init --recursive --depth 1

    # Don't define PL_EXPORT for static build
    # https://code.videolan.org/videolan/libplacebo/-/merge_requests/682
    sed -i "/c_args:/s/'-DPL_EXPORT'/'-DPL_STATIC'/" src/meson.build

    # FIXME: parse the file, then hand the root Element to VkXML
    # fixes `TypeError: expected an Element, not ElementTree` since python v3.14.0b4
    # https://github.com/haasn/libplacebo/issues/335
    sed -i 's|\(registry = VkXML(ET.parse(xmlfile)\)|\1.getroot()|' src/vulkan/utils_gen.py

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{d3d11,vulkan,shaderc}"=enabled"
        -D{bench,demos,fuzz,tests}"=false"
        -D{glslang,vk-proc-addr}"=disabled"
        -Dvulkan-registry="$FFBUILD_PREFIX"/share/vulkan/registry/vk.xml
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ..
    ninja -j"$(nproc)"
    ninja install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libplacebo.pc
}

ffbuild_configure() {
    echo --enable-libplacebo
}

ffbuild_unconfigure() {
    echo --disable-libplacebo
}
