#!/bin/bash
# run_stage <stage-script> [label]
#
# Runs one build stage.
#
# * If /stagelogs/.active exists (CI: `buildah build --volume DIR:/stagelogs`
#   with utils/stagelog-printer.sh watching DIR), the *whole* output of the
#   stage is captured to a file and handed over to the printer only when the
#   stage has finished. The container itself prints nothing, so output of
#   stages that run in parallel can never be mixed.
# * Otherwise (local docker/BuildKit build) the output is streamed as before.

STAGE_SCRIPT="$1"
LABEL="${2:-$1}"
LOGDIR=/stagelogs

build_stage() {
    set -xe
    mkdir -p /stage
    source "$STAGE_SCRIPT"
    cd /stage
    ffbuild_dockerbuild
    rm -rf /stage "${FFBUILD_PREFIX:?}"/{bin,share/doc}
}

if [[ ! -e "$LOGDIR/.active" ]]; then
    set -e
    ( build_stage )
    exit 0
fi

ID="$(</proc/sys/kernel/random/uuid)"
RUNNING="$LOGDIR/$ID.run"
PART="$LOGDIR/$ID.part"
printf '%s\n' "$LABEL" > "$RUNNING"

START=$SECONDS
# Subshell + `set +e` here: `set -e` must stay effective *inside* build_stage,
# which it would not be if the call were part of an if/||/&& list.
set +e
( build_stage ) > "$PART" 2>&1
RC=$?
DURATION=$((SECONDS - START))

# Publish atomically: the printer only looks at *.log, which appear by rename.
FINAL="$LOGDIR/$(date +%s%N)-${ID:0:8}"
{
    printf '%s\t%s\t%s\n' "$LABEL" "$RC" "$DURATION"
    cat "$PART"
} > "$FINAL.tmp"
mv "$FINAL.tmp" "$FINAL.log"
rm -f "$PART" "$RUNNING"

# Only a one-liner goes to the container's stdout (-> buildah's own log).
echo "[$LABEL] exit $RC after ${DURATION}s" >&2
exit "$RC"
