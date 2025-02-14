# syntax=docker/dockerfile:latest
FROM ghcr.io/nanake/fedora:rawhide AS base

RUN <<EOF
    dnf5 config-manager setopt assumeyes=True install_weak_deps=False max_parallel_downloads=20
    dnf5 install \
        autoconf \
        automake \
        byacc \
        clang \
        cmake \
        gawk \
        gcc \
        gcc-c++ \
        gettext-devel \
        git \
        glibc-devel \
        gperf \
        libtool \
        meson \
        nasm \
        ninja-build \
        patch \
        perl-FindBin \
        perl-IPC-Cmd \
        pkgconf-pkg-config \
        python-unversioned-command \
        python3 \
        ragel \
        texinfo \
        unzip \
        wget2-wget \
        which \
        xxd \
        yasm
    dnf5 clean all
    git config --system user.email "builder@localhost"
    git config --system user.name "Builder"
    git config --system advice.detachedHead false
EOF

RUN --mount=src=.,dst=/input <<EOF
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done
    cp input/cross.meson input/toolchain.cmake /
EOF

FROM base AS toolchain

RUN <<EOF
    dnf5 install mingw32-{gcc{,-c++},libgomp}
    dnf5 clean all
    find /usr/*mingw*/* -type f -name "*.dll*" -delete
    rm -rf /tmp/* /usr/share/doc/* /var/cache/* /var/lib/dnf/history.* /var/log/* /var/tmp/*
    mkdir /opt/ffbuild
EOF

ENV FFBUILD_TOOLCHAIN=i686-w64-mingw32
ENV FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- --arch=i686 --target-os=mingw32" \
    FFBUILD_CROSS_PREFIX=${FFBUILD_TOOLCHAIN}- \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CC="${FFBUILD_TOOLCHAIN}-gcc" \
    CXX="${FFBUILD_TOOLCHAIN}-g++" \
    LD="${FFBUILD_TOOLCHAIN}-ld" \
    AR="${FFBUILD_TOOLCHAIN}-gcc-ar" \
    RANLIB="${FFBUILD_TOOLCHAIN}-gcc-ranlib" \
    NM="${FFBUILD_TOOLCHAIN}-gcc-nm" \
    DLLTOOL="${FFBUILD_TOOLCHAIN}-dlltool" \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O3 -pipe -D_FORTIFY_SOURCE=3 -fstack-protector-strong -fno-semantic-interposition" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O3 -pipe -D_FORTIFY_SOURCE=3 -fstack-protector-strong -fno-semantic-interposition" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O3 -pipe -fstack-protector-strong"
