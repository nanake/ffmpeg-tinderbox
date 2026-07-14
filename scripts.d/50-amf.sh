#!/bin/bash

AMF_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
AMF_COMMIT="c35f613aea2e5057a688c979e75b1cf24253297e"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$AMF_REPO" "$AMF_COMMIT" amf
    cd amf

    mkdir -p "$FFBUILD_PREFIX"/include
    mv amf/public/include "$FFBUILD_PREFIX"/include/AMF
}

ffbuild_configure() {
    echo --enable-amf
}

ffbuild_unconfigure() {
    echo --disable-amf
}
