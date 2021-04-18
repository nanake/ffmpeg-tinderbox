#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/defaults-gpl-shared.sh
FF_CONFIGURE+=" --disable-doc --enable-nonfree --extra-version=nonfree"
