# syntax=docker/dockerfile:1.4
FROM ubuntu:kinetic

RUN <<EOF
    apt-get -y update
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
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
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
    update-ca-certificates
    git config --global user.email "builder@localhost"
    git config --global user.name "Builder"
    git config --global advice.detachedHead false
EOF

RUN --mount=src=.,dst=/input \
    for s in /input/*.sh; do cp $s /usr/bin/$(echo $s | sed -e 's|.*/||' -e 's/\.sh$//'); done
