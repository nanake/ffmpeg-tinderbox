#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]
}

ffbuild_dockerstage() {
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
