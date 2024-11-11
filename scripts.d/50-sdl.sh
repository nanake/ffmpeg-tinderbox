#!/bin/bash

SDL_SRC="https://github.com/libsdl-org/SDL/releases/download/release-2.30.9/SDL2-devel-2.30.9-mingw.tar.gz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    curl -L "$SDL_SRC" | tar xz
    cd SDL*

    if [[ $TARGET == win64 ]]; then
        cd x86_64-w64-mingw32
    elif [[ $TARGET == win32 ]]; then
        cd i686-w64-mingw32
    else
        echo "Unknown target"
        return -1
    fi

    cp -r include/. "$FFBUILD_PREFIX"/include/.
    cp lib/libSDL2.a "$FFBUILD_PREFIX"/lib
    cp lib/pkgconfig/sdl2.pc "$FFBUILD_PREFIX"/lib/pkgconfig

    sed -ri -e "s|^prefix=.*|prefix=${FFBUILD_PREFIX}|" \
        -e 's/ -mwindows//g' \
        -e 's/ -lSDL2main//g' \
        -e 's/ -Dmain=SDL_main//g' \
        -e 's/ -lSDL2//g' \
        -e 's/Libs: /Libs: -lSDL2 /' \
        "$FFBUILD_PREFIX"/lib/pkgconfig/sdl2.pc
}

ffbuild_configure() {
    echo --enable-sdl2
}

ffbuild_unconfigure() {
    echo --disable-sdl2
}
