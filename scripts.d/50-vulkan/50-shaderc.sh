#!/bin/bash

SHADERC_REPO="https://github.com/google/shaderc.git"
SHADERC_COMMIT="4dc596ddc2702092c670e828745dc3e0338d83c1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SHADERC_REPO" "$SHADERC_COMMIT" shaderc
    cd shaderc

    ./utils/git-sync-deps

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DSHADERC_SKIP_{COPYRIGHT_CHECK,EXAMPLES,TESTS}=ON \
        -DSHADERC_ENABLE_WERROR_COMPILE=OFF \
        -DENABLE_{CTEST,GLSLANG_BINARIES}=OFF \
        -DSKIP_{GLSLANG,SPIRV_TOOLS}_INSTALL=ON \
        -DSPIRV_{TOOLS_BUILD_STATIC,SKIP_EXECUTABLES}=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    # for some reason, this does not get installed...
    cp libshaderc_util/libshaderc_util.a "$FFBUILD_PREFIX"/lib

    echo "Libs: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/shaderc_combined.pc
    echo "Libs: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/shaderc_static.pc

    cp "$FFBUILD_PREFIX"/lib/pkgconfig/{shaderc_combined,shaderc}.pc

    rm "$FFBUILD_PREFIX"/lib/*.dll.a
}

ffbuild_configure() {
    echo --enable-libshaderc
}

ffbuild_unconfigure() {
    echo --disable-libshaderc
}
