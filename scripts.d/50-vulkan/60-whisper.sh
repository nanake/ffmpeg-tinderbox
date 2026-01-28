#!/bin/bash

WHISPER_REPO="https://github.com/ggml-org/whisper.cpp.git"
WHISPER_COMMIT="7aa8818647303b567c3a21fe4220b2681988e220"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$WHISPER_REPO" whisper
    cd whisper

    git checkout "$WHISPER_COMMIT"

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
        -DGGML_{CCACHE,NATIVE}=OFF \
        -DGGML_{AVX,AVX2,BMI2,F16C,FMA,SSE42,VULKAN}=ON \
        -DWHISPER_BUILD_{EXAMPLES,SERVER,TESTS}=OFF \
        -DWHISPER_USE_SYSTEM_GGML=OFF \
        -GNinja \
        ..

    ninja -j"$(nproc)"
    ninja install

    # For some reason, these lack the lib prefix on Windows
    shopt -s nullglob
    for libfile in "$FFBUILD_PREFIX"/lib/ggml*.a; do
        mv "${libfile}" "$(dirname "${libfile}")/lib$(basename "${libfile}")"
    done

    # Fix linking order and add required flags
    sed -i "s/^\(Libs:\).*$/\1 -L\${libdir} -lwhisper/" "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
    {
        echo "Cflags.private: -fopenmp"
        echo "Libs.private: -lggml -lggml-base -lggml-cpu -lggml-vulkan -lstdc++"
        echo "Requires: vulkan"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/whisper.pc
}

ffbuild_configure() {
    echo --enable-whisper
}

ffbuild_unconfigure() {
    echo --disable-whisper
}
