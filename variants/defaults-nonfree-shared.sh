#!/bin/bash
source "$(dirname "$BASH_SOURCE")"/defaults-gpl-shared.sh
FF_CONFIGURE+=" --enable-nonfree --extra-version=nonfree"
