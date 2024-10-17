#!/bin/bash
set -eo pipefail
shopt -s globstar
export LC_ALL=C

cd "$(dirname "$0")"/..

for scr in scripts.d/**/*.sh; do
    echo "Processing ${scr}"
    (
        source "$scr"

        if [[ -n "$SCRIPT_SKIP" ]]; then
            exit 0
        fi

        for REPO_VAR in $(compgen -v | grep '_REPO$'); do
            COMMIT_VAR="${REPO_VAR/_REPO/_COMMIT}"
            BRANCH_VAR="${REPO_VAR/_REPO/_BRANCH}"
            TAGFILTER_VAR="${REPO_VAR/_REPO/_TAGFILTER}"

            CUR_REPO="${!REPO_VAR}"
            CUR_COMMIT="${!COMMIT_VAR}"
            CUR_BRANCH="${!BRANCH_VAR}"
            CUR_TAGFILTER="${!TAGFILTER_VAR}"

            if [[ -z "${CUR_REPO}" ]]; then
                # Mark scripts without repo source for manual check
                echo "xxx_CHECKME_xxx" >> "$scr"
                echo "Needs manual check."
                break
            fi

            if [[ -n "${CUR_COMMIT}" ]]; then # GIT
                if [[ -n "${CUR_TAGFILTER}" ]]; then
                    NEW_COMMIT="$(git -c 'versionsort.suffix=-' ls-remote --exit-code --tags --refs --sort "v:refname" "${CUR_REPO}" "refs/tags/${CUR_TAGFILTER}" | tail -n1 | cut -d/ -f3- | xargs)"
                else
                    if [[ -z "${CUR_BRANCH}" ]]; then
                        # Fetch default branch name
                        CUR_BRANCH="$(git remote show "${CUR_REPO}" | grep "HEAD branch:" | cut -d":" -f2 | xargs)"
                        echo "Found default branch ${CUR_BRANCH}"
                    fi
                    NEW_COMMIT="$(git ls-remote --exit-code --heads --refs "${CUR_REPO}" refs/heads/"${CUR_BRANCH}" | cut -f1)"
                fi

                echo "Got ${NEW_COMMIT} (current: ${CUR_COMMIT})"

                if [[ "${NEW_COMMIT}" != "${CUR_COMMIT}" ]]; then
                    echo "Updating ${scr}"
                    sed -i "s/^${COMMIT_VAR}=.*/${COMMIT_VAR}=\"${NEW_COMMIT}\"/" "${scr}"
                fi
            else
                # Mark scripts with unknown layout for manual check
                echo "xxx_CHECKME_UNKNOWN_xxx" >> "$scr"
                echo "Unknown layout. Needs manual check."
                break
            fi
        done
    )
    echo
done
