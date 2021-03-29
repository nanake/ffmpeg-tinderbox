FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install \
        autoconf \
        automake \
        build-essential \
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
        yasm && \
    apt-get -y clean

COPY run_stage.sh /usr/bin/run_stage
COPY git-mini-clone.sh /usr/bin/git-mini-clone
COPY check-wget.sh /usr/bin/check-wget
