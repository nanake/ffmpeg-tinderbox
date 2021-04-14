#!/bin/bash

AOM_REPO="https://aomedia.googlesource.com/aom"
AOM_COMMIT="5c9bc4181071684d157fc47c736acf6c69a85d85"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$AOM_REPO" "$AOM_COMMIT" aom
    cd aom

    mkdir cmbuild && cd cmbuild

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_TESTS=OFF -DENABLE_TOOLS=OFF ..
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libaom
}

ffbuild_unconfigure() {
    echo --disable-libaom
}
