# syntax=docker/dockerfile:latest
FROM debian:trixie-slim AS base

RUN <<EOF
    apt update
    DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install \
        autoconf \
        automake \
        autopoint \
        build-essential \
        ca-certificates \
        clang \
        cmake \
        curl \
        gawk \
        gettext \
        git \
        gperf \
        libc6-dev \
        libtool \
        meson \
        nasm \
        ninja-build \
        pkgconf \
        python-is-python3 \
        python3-apt \
        python3-distutils \
        python3-mako \
        ragel \
        texi2html \
        texinfo \
        unzip \
        wget \
        xxd \
        yasm
    update-ca-certificates
    git config --global user.email "builder@localhost"
    git config --global user.name "Builder"
    git config --global advice.detachedHead false
EOF

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done

FROM base AS build

RUN <<EOF
    DEBIAN_FRONTEND=noninteractive apt -y --no-install-recommends install \
        binutils-mingw-w64-x86-64 \
        gcc-mingw-w64-x86-64-posix \
        g++-mingw-w64-x86-64-posix
    rm /usr/lib/gcc/*-w64-mingw32/*/libstdc++*.dll*
    rm /usr/lib/gcc/*-w64-mingw32/*/libgcc_s*
    rm /usr/lib/gcc/*-w64-mingw32/*/*.dll.a
    rm /usr/*-w64-mingw32/lib/*.dll.a
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
    mkdir /opt/ffbuild
EOF

COPY cross.meson toolchain.cmake /

ENV FFBUILD_TOOLCHAIN=x86_64-w64-mingw32
ENV FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=${FFBUILD_TOOLCHAIN}- --arch=x86_64 --target-os=mingw32" \
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
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong"
