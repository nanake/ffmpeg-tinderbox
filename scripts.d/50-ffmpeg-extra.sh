#!/bin/bash

ffbuild_enabled() {
    [[ $TARGET == win* ]]
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
    # alternatively, adding -Wno-error without any =foo work as well
    echo -fpermissive
}
