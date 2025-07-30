#!/bin/bash

X265_REPO="https://bitbucket.org/multicoreware/x265_git.git"
X265_COMMIT="8f11c33acc267ba3f1d2bde60a6aa906e494cbde"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$X265_REPO" x265
    cd x265
    git checkout "$X265_COMMIT"

    # workaround for gcc-15
    sed -i '/#include <limits>/a #include <cstdint>' source/dynamicHDR10/json11/json11.cpp

    local common_config=(
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX"
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN"
        -DCMAKE_BUILD_TYPE=Release
        -DENABLE_ALPHA=ON
        -DENABLE_{SHARED,CLI}"=OFF"
        -Wno-dev
        -GNinja
    )

    if [[ $TARGET != *32 ]]; then
        mkdir 8bit 10bit 12bit
        cmake "${common_config[@]}" -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_HDR10_PLUS=ON -DMAIN12=ON -S source -B 12bit &
        cmake "${common_config[@]}" -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_HDR10_PLUS=ON -S source -B 10bit &
        cmake "${common_config[@]}" -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_{10,12}BIT=ON -S source -B 8bit &
        wait

        cat >build.ninja <<"EOF"
rule build_lib
  command = ninja -C $in

build 12bit/libx265.a: build_lib 12bit
build 10bit/libx265.a: build_lib 10bit
build 8bit/libx265.a: build_lib 8bit

build all: phony 12bit/libx265.a 10bit/libx265.a 8bit/libx265.a
default all
EOF

        ninja -j"$(nproc)"

        cd 8bit
        mv ../12bit/libx265.a ../8bit/libx265_main12.a
        mv ../10bit/libx265.a ../8bit/libx265_main10.a
        mv libx265.a libx265_main.a

        ${AR} -M <<EOF
CREATE libx265.a
ADDLIB libx265_main.a
ADDLIB libx265_main10.a
ADDLIB libx265_main12.a
SAVE
END
EOF
    else
        mkdir 8bit
        cd 8bit
        cmake "${common_config[@]}" ../source
        ninja -j"$(nproc)"
    fi

    ninja install
}

ffbuild_configure() {
    echo --enable-libx265
}

ffbuild_unconfigure() {
    echo --disable-libx265
}
