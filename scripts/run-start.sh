#!/usr/bin/env bash
# Start of a routine run: sync state from the remote, validate, print a run id.
# Usage: eval "$(bash scripts/run-start.sh <routine-name>)"   (or just run it and read the output)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
routine="${1:-interactive}"
. scripts/lib.sh
configure_git

if git remote get-url origin >/dev/null 2>&1; then
  retry git fetch -q origin "$BRANCH" || true
  cur="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$cur" != "$BRANCH" ]; then
    git checkout -q "$BRANCH" 2>/dev/null || git checkout -q -b "$BRANCH" "origin/$BRANCH" 2>/dev/null || true
  fi
  if git rev-parse -q --verify "origin/$BRANCH" >/dev/null; then
    merge_with_state_driver "origin/$BRANCH" || log "run-start: could not merge origin/$BRANCH; continuing on local state"
  fi
  # Recover state a previous run had to park on the fallback branch.
  if retry git fetch -q origin "$FALLBACK" 2>/dev/null && git rev-parse -q --verify "origin/$FALLBACK" >/dev/null; then
    if ! git merge-base --is-ancestor "origin/$FALLBACK" HEAD; then
      if merge_with_state_driver "origin/$FALLBACK"; then
        log "run-start: recovered state from $FALLBACK"
        git push -q origin --delete "$FALLBACK" 2>/dev/null || true
      fi
    fi
  fi
fi

if [ -n "$UPSTREAM" ]; then
  git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM"
  if retry git fetch -q upstream main 2>/dev/null; then
    if ! git merge-base --is-ancestor upstream/main HEAD; then
      # Code updates from the template. state/ is always ours.
      if git merge -q --no-edit upstream/main >/dev/null 2>&1; then
        log "run-start: merged code updates from upstream"
      else
        git checkout -q --ours -- state/ 2>/dev/null || true
        git add -A state/ 2>/dev/null || true
        if git diff --name-only --diff-filter=U | grep -q .; then
          git merge --abort 2>/dev/null || true; log "run-start: upstream merge conflicted outside state/; skipped"
        else
          GIT_EDITOR=true git commit -q --no-edit 2>/dev/null || true; log "run-start: merged code updates from upstream (kept our state/)"
        fi
      fi
    fi
  fi
fi

bash scripts/validate-state.sh
run_id="$(date -u +%Y%m%dT%H%M%SZ)-${routine}"
mkdir -p state/runs
echo "$run_id" > state/runs/.current
printf 'RUN_ID=%s\nROUTINE=%s\nBRANCH=%s\nSTARTED=%s\n' "$run_id" "$routine" "$BRANCH" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
