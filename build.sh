#!/bin/bash
set -e
shopt -s globstar
cd "$(dirname "$0")"
source util/vars.sh

get_output() {
    (
        SELF="$1"
        source $1
        if ffbuild_enabled; then
            ffbuild_$2 || exit 0
        else
            ffbuild_un$2 || exit 0
        fi
    )
}

source "variants/${TARGET}-${VARIANT}.sh"

for addin in ${ADDINS[*]}; do
    source "addins/${addin}.sh"
done

export FFBUILD_PREFIX="$(docker run --rm "$IMAGE" bash -c 'echo $FFBUILD_PREFIX')"

for script in scripts.d/**/*.sh; do
    FF_CONFIGURE+=" $(get_output $script configure)"
    FF_CFLAGS+=" $(get_output $script cflags)"
    FF_CXXFLAGS+=" $(get_output $script cxxflags)"
    FF_LDFLAGS+=" $(get_output $script ldflags)"
    FF_LIBS+=" $(get_output $script libs)"
done

FF_CONFIGURE="$(xargs <<< "$FF_CONFIGURE")"
FF_CFLAGS="$(xargs <<< "$FF_CFLAGS")"
FF_CXXFLAGS="$(xargs <<< "$FF_CXXFLAGS")"
FF_LDFLAGS="$(xargs <<< "$FF_LDFLAGS")"
FF_LIBS="$(xargs <<< "$FF_LIBS")"

TESTFILE="uidtestfile"
rm -f "$TESTFILE"
docker run --rm -v "$PWD:/uidtestdir" "$IMAGE" touch "/uidtestdir/$TESTFILE"
DOCKERUID="$(stat -c "%u" "$TESTFILE")"
rm -f "$TESTFILE"
[[ "$DOCKERUID" != "$(id -u)" ]] && UIDARGS=( -u "$(id -u):$(id -g)" ) || UIDARGS=()

rm -rf ffbuild
mkdir ffbuild

FFMPEG_REPO="${FFMPEG_REPO:-https://github.com/FFmpeg/FFmpeg.git}"
FFMPEG_REPO="${FFMPEG_REPO_OVERRIDE:-$FFMPEG_REPO}"
GIT_BRANCH="${GIT_BRANCH:-master}"
GIT_BRANCH="${GIT_BRANCH_OVERRIDE:-$GIT_BRANCH}"

docker run --rm -i "${UIDARGS[@]}" -v $PWD/ffbuild:/ffbuild "$IMAGE" bash -s <<EOF
    set -xe
    cd /ffbuild
    rm -rf ffmpeg prefix

    git clone --filter=blob:none --branch='$GIT_BRANCH' --single-branch '$FFMPEG_REPO' ffmpeg
    cd ffmpeg

    ./configure --prefix=/ffbuild/prefix --pkg-config-flags="--static" \$FFBUILD_TARGET_FLAGS $FF_CONFIGURE \
        --extra-cflags="$FF_CFLAGS" --extra-cxxflags="$FF_CXXFLAGS" \
        --extra-ldflags="$FF_LDFLAGS" --extra-libs="$FF_LIBS"
    make -j\$(nproc)
    make install
EOF

mkdir -p artifacts
ARTIFACTS_PATH="$PWD/artifacts"
FFMPEG_VERSION="$(./ffbuild/ffmpeg/ffbuild/version.sh ffbuild/ffmpeg)"
BUILD_NAME="ffmpeg-${FFMPEG_VERSION//-g/-git-}-${TARGET}-${VARIANT}${ADDINS_STR:+-}${ADDINS_STR}"

mkdir -p "ffbuild/pkgroot/$BUILD_NAME"
package_variant ffbuild/prefix "ffbuild/pkgroot/$BUILD_NAME"

cd ffbuild/pkgroot
7z a -mx=9 "${ARTIFACTS_PATH}/${BUILD_NAME}.7z" "$BUILD_NAME"
cd -

rm -rf ffbuild
