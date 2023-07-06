#!/bin/bash

KVAZAAR_REPO="https://github.com/ultravideo/kvazaar.git"
KVAZAAR_COMMIT="e001c6a867068b448354d955363bd2ff7caf33d2"

ffbuild_enabled() {
    [[ $TARGET == ucrt64 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$KVAZAAR_REPO" "$KVAZAAR_COMMIT" kvazaar
    cd kvazaar

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    echo "Cflags.private: -DKVZ_STATIC_LIB" >> "$FFBUILD_PREFIX"/lib/pkgconfig/kvazaar.pc
}

ffbuild_configure() {
    echo --enable-libkvazaar
}

ffbuild_unconfigure() {
    echo --disable-libkvazaar
}
