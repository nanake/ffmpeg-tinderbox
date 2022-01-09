#!/bin/bash

ZVBI_SRC="https://sourceforge.net/projects/zapping/files/zvbi/0.2.35/zvbi-0.2.35.tar.bz2/download"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "RUN --mount=src=${SELF},dst=/stage.sh --mount=src=patches/zvbi,dst=/patches run_stage /stage.sh"
}

ffbuild_dockerbuild() {
    wget -O zvbi.tar.bz2 "$ZVBI_SRC"
    tar xaf zvbi.tar.bz2
    rm zvbi.tar.bz2
    cd zvbi*

    for patch in /patches/*.patch; do
        echo "Applying $patch"
        patch -p1 < "$patch"
    done

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{bktr,dvb,nls,proxy,shared}
        --enable-static
        --with-pic
        --without-{doxygen,x}
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -C src -j$(nproc)
    make -C src install
    make SUBDIRS=. install

    sed -i "s/\/[^ ]*libiconv.a/-liconv/" "$FFBUILD_PREFIX"/lib/pkgconfig/zvbi-0.2.pc
}

ffbuild_configure() {
    echo --enable-libzvbi
}

ffbuild_unconfigure() {
    echo --disable-libzvbi
}
