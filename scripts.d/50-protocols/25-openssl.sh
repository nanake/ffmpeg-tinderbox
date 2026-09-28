#!/bin/bash

OPENSSL_REPO="https://github.com/openssl/openssl.git"
OPENSSL_COMMIT="openssl-4.0.2"
OPENSSL_TAGFILTER="openssl-4.0.*"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENSSL_REPO" "$OPENSSL_COMMIT" openssl
    cd openssl

    local myconf=(
        no-{apps,deprecated,docs,legacy,makedepend,module,shared,tests}
        # Legacy cipher/digest implementations not required by either consumer.
        no-{bf,blake2,camellia,cast,dh,dsa,ec2m,idea,md2,md4,mdc2,rc2,rc4,rc5,rmd160,seed,sm2,sm3,sm4,whirlpool}
        # Unnecessary async/misc runtime features.
        no-{async,autoload-config,ui-console,multiblock,ssl-trace}
        # Unused libcrypto modules.
        no-{comp,ct,ocsp,cms,ts,srp,nextprotoneg,psk,srtp}
        # FFmpeg uses schannel for TLS on this target, while libssh and libsrt only use libcrypto (EVP/cipher primitives), thus completely eliminating the need for libssl and TLS/DTLS dependencies.
        no-{tls,dtls,dgram,quic}
        no-{tls1,tls1_1,tls1_2,dtls1,dtls1_2}-method
        threads
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
