#!/bin/bash

SHADERC_REPO="https://github.com/google/shaderc.git"
SHADERC_COMMIT="49d6a9328a07fe084a2ac018123e39696a441416"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SHADERC_REPO" "$SHADERC_COMMIT" shaderc
    cd shaderc

    ./utils/git-sync-deps

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_GLSLANG_BINARIES=OFF \
        -DSHADERC_ENABLE_WERROR_COMPILE=OFF \
        -DSHADERC_SKIP_{COPYRIGHT_CHECK,EXAMPLES,TESTS}=ON \
        -DSPIRV_{TOOLS_BUILD_STATIC,SKIP_EXECUTABLES}=ON \
        -DSPIRV_WERROR=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    # for some reason, this does not get installed...
    # https://github.com/google/shaderc/issues/1228
    cp libshaderc_util/libshaderc_util.a "$FFBUILD_PREFIX"/lib

    echo "Libs: -lstdc++" | tee -a "$FFBUILD_PREFIX"/lib/pkgconfig/shaderc_{combined,static}.pc

    cp "$FFBUILD_PREFIX"/lib/pkgconfig/{shaderc_combined,shaderc}.pc

    rm "$FFBUILD_PREFIX"/lib/*.dll.a

    # Build glslc for the host
    mkdir ../native_build && cd ../native_build

    unset CC CXX CFLAGS CXXFLAGS LD LDFLAGS AR RANLIB NM DLLTOOL PKG_CONFIG_LIBDIR
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DSHADERC_SKIP_{COPYRIGHT_CHECK,EXAMPLES,TESTS}=ON \
        -DSPIRV_TOOLS_BUILD_STATIC=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)" glslc/glslc

    cp glslc/glslc /usr/local/bin/glslc
}

ffbuild_configure() {
    echo --enable-libshaderc
}

ffbuild_unconfigure() {
    echo --disable-libshaderc
}
