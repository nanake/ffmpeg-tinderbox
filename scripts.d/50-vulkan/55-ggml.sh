#!/bin/bash

GGML_REPO="https://github.com/ggml-org/ggml.git"
GGML_COMMIT="facdc44a67da17df4433adcc468b424f48e9ded2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$GGML_REPO" "$GGML_COMMIT" ggml
    cd ggml

    mkdir build && cd build

    # vulkan-shaders-gen requires the host compiler g++ and its libstdc++.a
    # which is not available yet. In fact, vulkan-shaders-gen is a host tool,
    # hence, no need for static linking.
    unset CXXFLAGS LDFLAGS

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DGGML_{ALL_WARNINGS,BUILD_{EXAMPLES,TESTS},CCACHE,NATIVE}=OFF \
        -DGGML_{AVX,AVX2,BMI2,F16C,FMA,SSE42,STATIC,VULKAN}=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    # For some reason, these lack the lib prefix
    shopt -s nullglob
    for libfile in "$FFBUILD_PREFIX"/lib/ggml*.a; do
        mv "${libfile}" "$(dirname "${libfile}")/lib$(basename "${libfile}")"
    done
}
