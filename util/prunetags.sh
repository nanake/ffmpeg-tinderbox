#!/bin/bash
set -e
git fetch --tags
TAGS=( $(git tag -l "build-*" | sort -r) )

KEEP_LATEST=12
KEEP_MONTHLY=6

LATEST_TAGS=()
MONTHLY_TAGS=()

CUR_MONTH="-1"

for TAG in ${TAGS[@]}; do
    if [[ ${#LATEST_TAGS[@]} -lt ${KEEP_LATEST} ]]; then
        LATEST_TAGS+=( "$TAG" )
    fi

    if [[ ${#MONTHLY_TAGS[@]} -lt ${KEEP_MONTHLY} ]]; then
        TAG_MONTH="$(echo $TAG | cut -d- -f3)"

        if [[ ${TAG_MONTH} != ${CUR_MONTH} ]]; then
            CUR_MONTH="${TAG_MONTH}"
            MONTHLY_TAGS+=( "$TAG" )
        fi
    fi
done

for TAG in ${LATEST_TAGS[@]} ${MONTHLY_TAGS[@]}; do
    TAGS=( "${TAGS[@]/$TAG}" )
done

for TAG in ${TAGS[@]}; do
    echo "Deleting ${TAG}"
    hub release delete "${TAG}"
    git tag -d "${TAG}"
done

git push --tags --prune
