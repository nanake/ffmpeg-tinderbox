#!/bin/bash

OPENAPV_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
OPENAPV_COMMIT="e9ff45ec70792d9b50de5aa05c36646841b74109"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=main --single-branch "$OPENAPV_REPO" openapv
    cd openapv
    git checkout "$OPENAPV_COMMIT"

    echo > app/CMakeLists.txt

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTS=OFF \
        -DOAPV_APP_STATIC_BUILD=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    rm -rf "$FFBUILD_PREFIX"/include/oapv/oapv_exports.h

    # undone the API break
    # https://github.com/AcademySoftwareFoundation/openapv/commit/83937c6b005510781fbba18481289cb8df1238af#diff-6afeb7dc69a39db8f975381349feec8191f5e8d37f8769eb8c77764015e19faf
    # https://github.com/AcademySoftwareFoundation/openapv/pull/235
    # https://github.com/AcademySoftwareFoundation/openapv/issues/264
    # https://code.ffmpeg.org/FFmpeg/FFmpeg/pulls/24030
    cat << 'EOF' >> "$FFBUILD_PREFIX"/include/oapv/oapv.h

#ifndef OAPV_OLD_APISET
#define OAPV_OLD_APISET
#define oapvm_create(err) oapvm_create(&(oapvm_cdesc_t){ 0 }, (err))
#endif
EOF
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    echo --disable-liboapv
}
