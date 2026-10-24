#!/bin/bash

SHADERC_REPO="https://github.com/google/shaderc.git"
SHADERC_COMMIT="5bcaaaec711df4dfa31f38923d3d42b9b98d5250"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SHADERC_REPO" "$SHADERC_COMMIT" shaderc
    cd shaderc

    ./utils/git-sync-deps

    sed -i '/add_subdirectory(glslc)/d' CMakeLists.txt

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_GLSLANG_BINARIES=OFF \
        -DSHADERC_ENABLE_{HLSL,WERROR_COMPILE}=OFF \
        -DSHADERC_SKIP_{COPYRIGHT_CHECK,EXAMPLES,EXECUTABLES,TESTS}=ON \
        -DSPIRV_{TOOLS_BUILD_STATIC,SKIP_EXECUTABLES}=ON \
        -DSPIRV_WERROR=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)" shaderc_combined shaderc_combined-pkg-config
    install -Dm644 libshaderc/libshaderc_combined.a "$FFBUILD_PREFIX/lib/libshaderc_combined.a"
    install -Dm644 shaderc_combined.pc "$FFBUILD_PREFIX/lib/pkgconfig/shaderc_combined.pc"
    install -Dm644 -t "$FFBUILD_PREFIX/include/shaderc" ../libshaderc/include/shaderc/*.h ../libshaderc/include/shaderc/*.hpp

    echo "Libs: -lstdc++" >> "$FFBUILD_PREFIX"/lib/pkgconfig/shaderc_combined.pc

    cp "$FFBUILD_PREFIX"/lib/pkgconfig/{shaderc_combined,shaderc}.pc
}
