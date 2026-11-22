#!/bin/bash
# stagelog-printer.sh <logdir>
#
# The ONLY process that writes stage logs to the console.  Stages (see
# images/base-win64/run_stage.sh) drop finished logs into <logdir>; this script
# prints them one at a time, each as one uninterrupted block, in completion
# order.  Exits after <logdir>/.finished has appeared and everything has been
# printed.
set -u
shopt -s nullglob
DIR="$1"
HEARTBEAT="${HEARTBEAT:-60}"

in_actions=0
[[ -n "${GITHUB_ACTIONS:-}" ]] && in_actions=1

emit() {
    local f="$1" label rc secs token
    IFS=$'\t' read -r label rc secs < "$f"
    token="stage-$RANDOM$RANDOM$RANDOM"

    if (( rc == 0 )); then
        # Collapsed group. `stop-commands` keeps stray "::xyz::" lines inside
        # a build log from being interpreted as workflow commands.
        (( in_actions )) && echo "::group::[$label] done in ${secs}s"
        (( in_actions )) && echo "::stop-commands::$token"
        tail -n +2 "$f"
        (( in_actions )) && echo "::$token::"
        (( in_actions )) && echo "::endgroup::"
        (( in_actions )) || echo "[$label] done in ${secs}s"
    else
        # Failed stages are never collapsed.
        (( in_actions )) && echo "::error title=Stage failed::[$label] exit code $rc after ${secs}s"
        echo "===== [$label] FAILED (exit $rc) after ${secs}s ====="
        (( in_actions )) && echo "::stop-commands::$token"
        tail -n +2 "$f"
        (( in_actions )) && echo "::$token::"
        echo "===== end of [$label] ====="
    fi
}

touch "$DIR/.active"
last_report=$SECONDS
last_running=""

while :; do
    # Sample the flag BEFORE listing: everything a stage published before the
    # build ended is then guaranteed to be in the listing below.
    finished=0
    [[ -e "$DIR/.finished" ]] && finished=1

    for f in "$DIR"/*.log; do        # glob is sorted -> completion order
        emit "$f"
        rm -f "$f"
        last_report=$SECONDS
    done

    if (( finished )); then
        # Stages killed before they could publish (OOM, cancel, ...).
        for f in "$DIR"/*.part; do
            echo "===== incomplete log (stage was killed) ====="
            cat "$f"
            rm -f "$f"
        done
        break
    fi

    # Sign of life: one line, from this process, so it cannot interleave either.
    if (( SECONDS - last_report >= HEARTBEAT )); then
        running="$(cat "$DIR"/*.run 2>/dev/null | sort | paste -sd, -)"
        echo "... still running: ${running:-(none)}"
        last_report=$SECONDS
    fi
    sleep 1
done
