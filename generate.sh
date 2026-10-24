#!/bin/bash
set -e
cd "$(dirname "$0")"
source utils/vars.sh

rm -f Dockerfile

layername() {
    printf "layer-"
    basename "$1" | sed 's/.sh$//'
}

exec_dockerstage() {
    SCRIPT="$1"
    (
        SELF="$SCRIPT"
        source "$SCRIPT"
        ffbuild_enabled || exit 0
        ffbuild_dockerstage || exit $?
    )
}

to_df() {
    _of="${TODF:-Dockerfile}"
    printf "$@" >> "$_of"
    echo >> "$_of"
}

to_df "# syntax=docker/dockerfile:latest"
to_df "FROM ${REGISTRY}/${OWNER}/base-${TARGET}:latest AS base"
to_df "ENV TARGET=$TARGET VARIANT=${VARIANT%-shared} OWNER=$OWNER REPO=$REPO"

PREVLAYER="base"
for ID in $(ls -1d scripts.d/??-* | sed -s 's|^.*/\(..\).*|\1|' | sort -u); do
    LAYER="layer-$ID"

    for STAGE in scripts.d/$ID-*; do
    if [[ -f "$STAGE" ]]; then
        ( source "$STAGE"; ffbuild_enabled ) || continue
        to_df "FROM $PREVLAYER AS $(layername "$STAGE")"
        exec_dockerstage "$STAGE"
    else
        to_df "FROM $PREVLAYER AS $(layername "$STAGE")"
        for STAGE in "${STAGE}"/??-*; do
            exec_dockerstage "$STAGE"
        done
    fi
done

    to_df "FROM $PREVLAYER AS $LAYER"
    for STAGE in scripts.d/$ID-*; do
        if [[ -f "$STAGE" ]]; then
            SCRIPT="$STAGE"
            DIR_ENABLED=1
            ( source "$SCRIPT"; ffbuild_enabled ) && DIR_ENABLED=0
        else
            SCRIPTS=( "$STAGE"/??-* )
            SCRIPT="${SCRIPTS[-1]}"
            DIR_ENABLED=1
            for S in "${SCRIPTS[@]}"; do
                ( source "$S"; ffbuild_enabled ) && DIR_ENABLED=0 && break
            done
        fi

        [[ $DIR_ENABLED -eq 0 ]] || continue

        (
            SELF="$SCRIPT"
            SELFLAYER="$(layername "$STAGE")"
            source "$SCRIPT"
            ffbuild_dockerlayer || exit $?
            TODF="Dockerfile.final" PREVLAYER="__PREVLAYER__" \
                ffbuild_dockerfinal || exit $?
        )
    done

    PREVLAYER="$LAYER"
done

to_df "FROM base"
sed "s/__PREVLAYER__/$PREVLAYER/g" Dockerfile.final | sort -u >> Dockerfile
rm Dockerfile.final
