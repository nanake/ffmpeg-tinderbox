#!/bin/bash

VAPOURSYNTH_REPO="https://github.com/vapoursynth/vapoursynth.git"
VAPOURSYNTH_COMMIT="ba20f3ed42eb1eaf480ddddfb76f9cd07573b2e0"


ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VAPOURSYNTH_REPO" "$VAPOURSYNTH_COMMIT" vapoursynth
    cd vapoursynth

    mkdir -p "$FFBUILD_PREFIX"/include/vapoursynth "$FFBUILD_PREFIX"/lib/pkgconfig
    cp include/*.h "$FFBUILD_PREFIX"/include/vapoursynth

    cat <<EOF >"$FFBUILD_PREFIX"/lib/pkgconfig/vapoursynth.pc
prefix=$FFBUILD_PREFIX
includedir=\${prefix}/include/vapoursynth
Name: vapoursynth
Description: A frameserver for the 21st century
Version: $(awk '{print $3}' VAPOURSYNTH_VERSION)
Cflags: -I\${includedir}
EOF
}

ffbuild_configure() {
    echo --enable-vapoursynth
}

ffbuild_unconfigure() {
    echo --disable-vapoursynth
}
