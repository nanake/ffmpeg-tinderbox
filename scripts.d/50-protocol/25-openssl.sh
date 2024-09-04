#!/bin/bash

OPENSSL_REPO="https://github.com/openssl/openssl.git"
OPENSSL_COMMIT="openssl-3.3.2"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENSSL_REPO" "$OPENSSL_COMMIT" openssl
    cd openssl

    local myconf=(
        no-{apps,docs,ec2m,legacy,module,shared,tests}
        no-{ssl,ssl3-method}
        no-{dh,dsa,md4,mdc2,rc2,rc4,sm2,sm3,sm4}
        threads
        zlib
        --prefix="$FFBUILD_PREFIX"
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            # (win64) install libraries onto lib not lib64
            # otherwise srt fails to find libcrypto
            # see https://github.com/openssl/openssl/issues/16244
            --libdir=lib
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            mingw64
        )
    elif [[ $TARGET == win32 ]]; then
        myconf+=(
            --cross-compile-prefix="$FFBUILD_CROSS_PREFIX"
            mingw
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CC="${CC/${FFBUILD_CROSS_PREFIX}/}"
    export CXX="${CXX/${FFBUILD_CROSS_PREFIX}/}"
    export AR="${AR/${FFBUILD_CROSS_PREFIX}/}"
    export RANLIB="${RANLIB/${FFBUILD_CROSS_PREFIX}/}"

    ./Configure "${myconf[@]}"

    make -j"$(nproc)"
    make install_sw
}
