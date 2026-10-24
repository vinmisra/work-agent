#!/usr/bin/env bash
# End of a routine run: housekeeping, validate, commit state, merge the remote, push with retry.
# Usage: bash scripts/run-end.sh "<one line summary>"
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
summary="${1:-agent run}"
. scripts/lib.sh
configure_git
run_id="$(cat state/runs/.current 2>/dev/null || date -u +%Y%m%dT%H%M%SZ)-end"

# Housekeeping: move closed items older than 14 days to the ledger, delete run notes older than 60 days.
python3 -I - <<'PY'
import json, datetime, glob, os
now = datetime.datetime.now(datetime.timezone.utc)
q = json.load(open("state/queue.json"))
keep, moved = [], []
for it in q.get("items", []):
    closed = it.get("closed_at")
    if it.get("status") in ("posted","rejected","expired","done","draft_in_gmail") and closed:
        try: age = now - datetime.datetime.fromisoformat(closed.replace("Z","+00:00"))
        except ValueError: age = datetime.timedelta(0)
        if age.days >= 14: moved.append(it); continue
    keep.append(it)
if moved:
    with open("state/ledger.jsonl","a") as f:
        for it in moved: f.write(json.dumps(it, separators=(",",":"))+"\n")
    q["items"] = keep
    json.dump(q, open("state/queue.json","w"), indent=2); open("state/queue.json","a").write("\n")
for f in glob.glob("state/runs/*.md"):
    try:
        when = datetime.datetime.strptime(os.path.basename(f)[:15], "%Y%m%dT%H%M%S").replace(tzinfo=datetime.timezone.utc)
        if (now - when).days > 60: os.remove(f)
    except ValueError: pass
PY

bash scripts/validate-state.sh
rm -f state/runs/.current
git add -A state/
if git diff --cached --quiet; then log "run-end: no state changes to commit"; exit 0; fi
git commit -q -m "state: ${summary} (${run_id})"
ours="$(git rev-parse HEAD)"

git remote get-url origin >/dev/null 2>&1 || { log "run-end: no origin remote; state committed locally only"; exit 0; }

push_to() {
  local target="$1" i
  for i in 1 2 3 4; do
    retry git fetch -q origin "$target" 2>/dev/null || true
    if git rev-parse -q --verify "origin/$target" >/dev/null; then
      if ! merge_with_state_driver "origin/$target"; then
        log "run-end: could not merge origin/$target cleanly"; return 1
      fi
    fi
    if git push -q origin "HEAD:$target" 2>/dev/null; then log "run-end: pushed state to $target"; return 0; fi
    sleep $((2 ** i))
  done
  return 1
}

if push_to "$BRANCH"; then exit 0; fi
log "run-end: push to $BRANCH failed; parking this run's state on $FALLBACK"
git reset -q --hard "$ours"
if push_to "$FALLBACK"; then
  log "run-end: state parked on $FALLBACK; the next run-start will merge it back into $BRANCH"
  exit 0
fi
log "run-end: PUSH FAILED. State is committed locally in this session only (commit $ours)."
exit 2
