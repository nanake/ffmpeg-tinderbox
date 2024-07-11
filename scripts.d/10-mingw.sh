#!/bin/bash

MINGW_REPO="https://github.com/mingw-w64/mingw-w64.git"
MINGW_COMMIT="a751e6401f3417a53544b2e0ea0b51274686e856"

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
    # deps build bustage with undefined reference to `_imp___stat32i64'
    # regressed by https://github.com/mingw-w64/mingw-w64/commit/4f96852
    if [[ $TARGET == win32 ]]; then
        MINGW_COMMIT="cc6afd4919d1721c19a1598570be22a00b04bae9"
    fi

    git-mini-clone "$MINGW_REPO" "$MINGW_COMMIT" mingw
    cd mingw

    cd mingw-w64-headers

    unset CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_LIBDIR

    SYSROOT="$($CC -print-sysroot)"

    local myconf=(
        --prefix="$SYSROOT/mingw"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    if [[ $TARGET != win64 ]]; then
        myconf+=(
            --with-default-msvcrt=msvcrt
        )
    fi

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
