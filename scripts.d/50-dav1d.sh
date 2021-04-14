#!/bin/bash

DAV1D_REPO="https://github.com/videolan/dav1d.git"
DAV1D_COMMIT="ae8958bdc7d30847158eafcec14552213708402f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$DAV1D_REPO" "$DAV1D_COMMIT" dav1d
    cd dav1d

    mkdir build && cd build

    export CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libdav1d
}

ffbuild_unconfigure() {
    echo --disable-libdav1d
}
