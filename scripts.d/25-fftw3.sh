#!/bin/bash

FFTW_SRC="https://fftw.org/pub/fftw/fftw-3.3.10.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$FFTW_SRC" | tar xz
    cd fftw*

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{shared,doc,fortran}
        --enable-{static,avx,avx2,maintainer-mode,sse2,threads}
        --with-{combined-threads,incoming-stack-boundary=2,our-malloc}
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}
