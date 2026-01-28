#!/bin/bash

OPENAL_REPO="https://github.com/kcat/openal-soft.git"
OPENAL_COMMIT="a147737a36d43f15d355aac05fd2e879b06ead19"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENAL_REPO" "$OPENAL_COMMIT" openal
    cd openal

    mkdir cmbuild && cd cmbuild

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DLIBTYPE=STATIC \
        -DALSOFT_{EXAMPLES,UTILS}=OFF \
        -DALSOFT_INSTALL_{AMBDEC_PRESETS,CONFIG,EXAMPLES,HRTF_DATA,UTILS}=OFF \
        -DALSOFT_BACKEND_{JACK,OPENSL,PIPEWIRE,PORTAUDIO,PULSEAUDIO}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private.*/& -lstdc++ -lole32 -luuid/' "$FFBUILD_PREFIX"/lib/pkgconfig/openal.pc
}

ffbuild_configure() {
    echo --enable-openal
}

ffbuild_unconfigure() {
    echo --disable-openal
}
