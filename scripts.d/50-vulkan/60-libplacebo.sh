#!/bin/bash

PLACEBO_REPO="https://github.com/haasn/libplacebo.git"
PLACEBO_COMMIT="2836ded2254c400e7fb7b93435c588474947c828"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$PLACEBO_REPO" "$PLACEBO_COMMIT" placebo
    cd placebo
    git submodule update --init --recursive --depth 1

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
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

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install

    echo "Libs.private: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/libplacebo.pc
}

ffbuild_configure() {
    echo --enable-libplacebo
}

ffbuild_unconfigure() {
    echo --disable-libplacebo
}
