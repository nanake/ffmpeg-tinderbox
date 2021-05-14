FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y update && \
    apt-get -y --no-install-recommends install \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        clang \
        cmake \
        curl \
        gawk \
        git \
        gperf \
        libc6-dev \
        libtool \
        meson \
        nasm \
        ninja-build \
        pkgconf \
        ragel \
        subversion \
        texi2html \
        texinfo \
        unzip \
        wget \
        xxd \
        yasm && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* && \
    update-ca-certificates

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done
