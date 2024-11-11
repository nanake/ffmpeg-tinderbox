#!/bin/bash

SHADERC_REPO="https://github.com/google/shaderc.git"
SHADERC_COMMIT="ddac450a36a3be28a2c2173f26703249dd83cfdf"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SHADERC_REPO" "$SHADERC_COMMIT" shaderc
    cd shaderc

    sed -i 's/d0e67c58134377f065a509845ca6b7d463f5b487/9c644fcb5b9a1a9c975c50a790fd14c5451292b0/' DEPS

    ./utils/git-sync-deps

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_GLSLANG_BINARIES=OFF \
        -DSHADERC_ENABLE_WERROR_COMPILE=OFF \
        -DSHADERC_SKIP_{COPYRIGHT_CHECK,EXAMPLES,TESTS}=ON \
        -DSPIRV_{TOOLS_BUILD_STATIC,SKIP_EXECUTABLES}=ON \
        -DSPIRV_WERROR=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    # for some reason, this does not get installed...
    # https://github.com/google/shaderc/issues/1228
    cp libshaderc_util/libshaderc_util.a "$FFBUILD_PREFIX"/lib

    echo "Libs: -lstdc++" | tee -a "$FFBUILD_PREFIX"/lib/pkgconfig/shaderc_{combined,static}.pc

    cp "$FFBUILD_PREFIX"/lib/pkgconfig/{shaderc_combined,shaderc}.pc

    rm "$FFBUILD_PREFIX"/lib/*.dll.a
}

ffbuild_configure() {
    echo --enable-libshaderc
}

ffbuild_unconfigure() {
    echo --disable-libshaderc
}
