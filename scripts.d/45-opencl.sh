#!/bin/bash

HEADERS_REPO="https://github.com/KhronosGroup/OpenCL-Headers.git"
HEADERS_COMMIT="f6f5aa533a62f3436f42f4b3a45cb4d8de8b6c32"

LOADER_REPO="https://github.com/KhronosGroup/OpenCL-ICD-Loader.git"
LOADER_COMMIT="c2cbdb33605ef9cfa02aa2a77e9cd7306c57e32a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    mkdir opencl && cd opencl

    git-mini-clone "$HEADERS_REPO" "$HEADERS_COMMIT" headers
    mkdir -p "$FFBUILD_PREFIX"/include/CL
    cp -r headers/CL/* "$FFBUILD_PREFIX"/include/CL/.

    git-mini-clone "$LOADER_REPO" "$LOADER_COMMIT" loader
    cd loader

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DOPENCL_ICD_LOADER_HEADERS_DIR="$FFBUILD_PREFIX"/include \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    cat >"$FFBUILD_PREFIX"/lib/pkgconfig/OpenCL.pc <<EOF
prefix=$FFBUILD_PREFIX
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: OpenCL
Description: OpenCL ICD Loader
Version: 9999
Libs: -L\${libdir} -l:OpenCL.a
Libs.private: -lole32 -lshlwapi -lcfgmgr32
Cflags: -I\${includedir}
EOF
}

ffbuild_configure() {
    echo --enable-opencl
}

ffbuild_unconfigure() {
    echo --disable-opencl
}
