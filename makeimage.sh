#!/bin/bash
set -xe
cd "$(dirname "$0")"
source util/vars.sh

docker buildx build --tag "$BASE_IMAGE" images/base
docker buildx build --build-arg GH_OWNER="$OWNER" --tag "$TARGET_IMAGE" "images/base-${TARGET}"

./generate.sh "$TARGET" "$VARIANT" "${ADDINS[@]}"

exec docker buildx build --tag "$IMAGE" .
