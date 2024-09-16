#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET == win32 ]]
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

ffbuild_cflags() {
    # triggered by https://github.com/FFmpeg/FFmpeg/commit/f85d947
    echo -Wno-error=int-conversion
}
