#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET == win* ]] && return -1
}

ffbuild_dockerstage() {
    return 0
}

ffbuild_dockerlayer() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}

ffbuild_configure() {
    echo --enable-schannel
}

ffbuild_unconfigure() {
    echo --disable-schannel
}
