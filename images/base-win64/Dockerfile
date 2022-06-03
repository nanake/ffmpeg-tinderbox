# syntax=docker/dockerfile:1.4
ARG GH_OWNER=nanake
FROM ghcr.io/$GH_OWNER/base:latest

RUN <<EOF
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install binutils-mingw-w64-x86-64 gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
    rm /usr/lib/gcc/*-w64-mingw32/*/libstdc++*.dll*
    rm /usr/lib/gcc/*-w64-mingw32/*/libgcc_s*
    rm /usr/lib/gcc/*-w64-mingw32/*/*.dll.a
    rm /usr/*-w64-mingw32/lib/*.dll.a
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
    mkdir /opt/ffbuild
EOF

COPY cross.meson toolchain.cmake /

ENV FFBUILD_TARGET_FLAGS="--pkg-config=pkg-config --cross-prefix=x86_64-w64-mingw32- --arch=x86_64 --target-os=mingw32" \
    FFBUILD_TOOLCHAIN=x86_64-w64-mingw32 \
    FFBUILD_CROSS_PREFIX=x86_64-w64-mingw32- \
    FFBUILD_PREFIX=/opt/ffbuild \
    FFBUILD_CMAKE_TOOLCHAIN=/toolchain.cmake \
    PKG_CONFIG=pkg-config \
    PKG_CONFIG_LIBDIR=/opt/ffbuild/lib/pkgconfig:/opt/ffbuild/share/pkgconfig \
    CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2 -pipe -D_FORTIFY_SOURCE=2 -fstack-protector-strong" \
    LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2 -pipe -fstack-protector-strong"
