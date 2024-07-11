#!/bin/bash

AMF_REPO="https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git"
AMF_COMMIT="6d7bec0469961e2891c6e1aaa5122b76ed82e1db"

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
