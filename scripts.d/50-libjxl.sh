#!/bin/bash

JXL_REPO="https://github.com/libjxl/libjxl.git"
JXL_COMMIT="b42db1b4872f835f610d536a96822f4f1a41e613"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$JXL_REPO" "$JXL_COMMIT" jxl
    cd jxl

    git submodule update --init --recursive --depth 1 --recommend-shallow third_party/highway

    mkdir build && cd build

    # Fix AVX2 proc (64bit) crash by highway due to unaligned stack memory
    if [[ $TARGET == win64 ]]; then
        export CXXFLAGS="$CXXFLAGS -Wa,-muse-unaligned-vector-move"
        export CFLAGS="$CFLAGS -Wa,-muse-unaligned-vector-move"
    fi

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DJPEGXL_BUNDLE_LIBPNG=OFF \
        -DJPEGXL_ENABLE_{BENCHMARK,DEVTOOLS,DOXYGEN,EXAMPLES,JNI,MANPAGES,PLUGINS,SJPEG,SKCMS,TOOLS,VIEWERS}=OFF \
        -DJPEGXL_ENABLE_HWY_AVX3{,_SPR,_ZEN4}=ON \
        -DJPEGXL_FORCE_SYSTEM_{BROTLI,LCMS2}=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)" hwy jxl jxl_cms jxl_threads
    install -Dm644 third_party/highway/libhwy.a "$FFBUILD_PREFIX/lib/libhwy.a"
    install -Dm644 third_party/highway/libhwy.pc "$FFBUILD_PREFIX/lib/pkgconfig/libhwy.pc"
    install -Dm644 -t "$FFBUILD_PREFIX/include/hwy" ../third_party/highway/hwy/*.h ../third_party/highway/hwy/ops/*.h

    install -Dm644 -t "$FFBUILD_PREFIX/lib" lib/libjxl.a lib/libjxl_cms.a lib/libjxl_threads.a
    install -Dm644 -t "$FFBUILD_PREFIX/lib/pkgconfig" lib/libjxl.pc lib/libjxl_cms.pc lib/libjxl_threads.pc
    install -Dm644 -t "$FFBUILD_PREFIX/include/jxl" lib/include/jxl/*.h

    echo "Libs.private: -lstdc++ -ladvapi32" | tee -a "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl{,_threads}.pc
}

ffbuild_configure() {
    echo --enable-libjxl
}

ffbuild_unconfigure() {
    echo --disable-libjxl
}
