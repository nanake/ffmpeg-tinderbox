#!/bin/bash

MINGW_REPO="https://github.com/mingw-w64/mingw-w64.git"
MINGW_COMMIT="b45bcc136eaa697b5bde3a5949b45f3c91b4a1ff"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /"
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /opt/mingw"
}

ffbuild_dockerfinal() {
    to_df "COPY --from=${PREVLAYER} /opt/mingw/. /"
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_REPO" "$MINGW_COMMIT" mingw
    cd mingw/mingw-w64-headers

    unset CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_LIBDIR

    SYSROOT="$($CC -print-sysroot)"

    local myconf=(
        --prefix="$SYSROOT/mingw"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install DESTDIR="/opt/mingw"

    cd ../mingw-w64-libraries/winpthreads

    local myconf=(
        --prefix="$SYSROOT/mingw"
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install DESTDIR="/opt/mingw"
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
