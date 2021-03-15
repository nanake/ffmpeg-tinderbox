FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install build-essential yasm nasm pkgconf git curl wget cmake unzip subversion autoconf automake libtool clang texinfo texi2html gperf ragel libc6-dev gawk meson ninja-build && \
    apt-get -y clean

ADD run_stage.sh /usr/bin/run_stage
ADD git-mini-clone.sh /usr/bin/git-mini-clone
ADD check-wget.sh /usr/bin/check-wget
