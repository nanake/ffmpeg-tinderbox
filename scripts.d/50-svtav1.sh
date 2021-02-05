#!/bin/bash

SVTAV1_REPO="https://github.com/OpenVisualCloud/SVT-AV1.git"
SVTAV1_COMMIT="ec7ac87f7fbfb2bbe0637ce0639f52ab41f10bcc"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    [[ $ADDINS_STR == *4.3* ]] && return -1
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git clone "$SVTAV1_REPO" svtav1
    cd svtav1
    git checkout "$SVTAV1_COMMIT"

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DBUILD_APPS=OFF -DENABLE_AVX512=ON ..
    make -j$(nproc)
    make install

    cd ../..
    rm -rf svtav1
}

ffbuild_configure() {
    echo --enable-libsvtav1
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *4.3* ]] && return 0
    echo --disable-libsvtav1
}
