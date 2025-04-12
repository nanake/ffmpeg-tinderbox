#!/bin/bash

OPENMPT_REPO="https://github.com/OpenMPT/openmpt.git"
OPENMPT_COMMIT="99880303f2501426f5434e5e53a8bf6ab4940c6a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENMPT_REPO" "$OPENMPT_COMMIT" openmpt
    cd openmpt

    local myconf=(
        PREFIX="$FFBUILD_PREFIX"
        CONFIG=mingw-w64
        CXXSTDLIB_PCLIBSPRIVATE="-lstdc++"
        STATIC_LIB=1
        SHARED_LIB=0
        DYNLINK=0
        EXAMPLES=0
        OPENMPT123=0
        IN_OPENMPT=0
        XMP_OPENMPT=0
        DEBUG=0
        OPTIMIZE=1
        TEST=0
        MODERN=1
        FORCE_DEPS=1
        NO_MINIMP3=0
        NO_ZLIB=0
        NO_OGG=0
        NO_VORBIS=0
        NO_VORBISFILE=0
        NO_MPG123=1
        NO_SDL2=1
        NO_PULSEAUDIO=1
        NO_SNDFILE=1
        NO_PORTAUDIO=1
        NO_PORTAUDIOCPP=1
        NO_FLAC=1
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            WINDOWS_ARCH=amd64
        )
    elif [[ $TARGET == win32 ]]; then
        myconf+=(
            WINDOWS_ARCH=x86
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CPPFLAGS="$CPPFLAGS -DMPT_WITH_MINGWSTDTHREADS"

    make -j"$(nproc)" "${myconf[@]}" all install
}

ffbuild_configure() {
    echo --enable-libopenmpt
}

ffbuild_unconfigure() {
    echo --disable-libopenmpt
}
