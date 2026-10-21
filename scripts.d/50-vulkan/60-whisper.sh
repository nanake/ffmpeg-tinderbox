#!/bin/bash

WHISPER_REPO="https://github.com/ggml-org/whisper.cpp.git"
WHISPER_COMMIT="231638a0717b7822784297e5980965ffcec05810"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$WHISPER_REPO" whisper
    cd whisper

    git checkout "$WHISPER_COMMIT"

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DWHISPER_BUILD_{EXAMPLES,SERVER,TESTS}=OFF \
        -DWHISPER_USE_SYSTEM_GGML=ON \
        -GNinja \
        ..

    ninja -j"$(nproc)"
    ninja install

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
