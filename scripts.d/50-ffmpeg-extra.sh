#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET == win64 ]]
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
    echo -fpermissive
}
