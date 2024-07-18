#!/bin/bash

SPIRV_CROSS_REPO="https://github.com/KhronosGroup/SPIRV-Cross.git"
SPIRV_CROSS_COMMIT="68d401117c85219ee6b2aba9a0cded314c55798f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SPIRV_CROSS_REPO" "$SPIRV_CROSS_COMMIT" spirv-cross
    cd spirv-cross

    VER_MAJ="$(grep 'set(spirv-cross-abi-major' CMakeLists.txt | sed -re 's/.* ([0-9]+)\)/\1/')"
    VER_MIN="$(grep 'set(spirv-cross-abi-minor' CMakeLists.txt | sed -re 's/.* ([0-9]+)\)/\1/')"
    VER_PCH="$(grep 'set(spirv-cross-abi-patch' CMakeLists.txt | sed -re 's/.* ([0-9]+)\)/\1/')"
    VER_FULL="$VER_MAJ.$VER_MIN.$VER_PCH"

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DSPIRV_CROSS_{SHARED,CLI,ENABLE_{CPP,TESTS}}=OFF \
        -DSPIRV_CROSS_{FORCE_PIC,STATIC}=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    cat >"$FFBUILD_PREFIX"/lib/pkgconfig/spirv-cross-c-shared.pc <<EOF
prefix=$FFBUILD_PREFIX
exec_prefix=\${prefix}
libdir=\${prefix}/lib
sharedlibdir=\${prefix}/lib
includedir=\${prefix}/include/spirv_cross

Name: spirv-cross-c-shared
Description: C API for SPIRV-Cross
Version: $VER_FULL

Requires:
Libs: -L\${libdir} -L\${sharedlibdir} -lspirv-cross-c -lspirv-cross-glsl -lspirv-cross-hlsl -lspirv-cross-reflect -lspirv-cross-msl -lspirv-cross-util -lspirv-cross-core -lstdc++
Cflags: -I\${includedir}
EOF
}
