#!/bin/bash

AOM_REPO="https://aomedia.googlesource.com/aom"
AOM_COMMIT="a240324b9c26ac823d5ead23407687a159d89566"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$AOM_REPO" "$AOM_COMMIT" aom
    cd aom

    mkdir cmbuild && cd cmbuild

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=0 \
        -DENABLE_{DOCS,EXAMPLES,TESTS,TOOLS}=0 \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libaom
}

ffbuild_unconfigure() {
    echo --disable-libaom
}
