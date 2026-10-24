#!/usr/bin/env bash
# Self-test for the state scripts. Needs only git and python3; no connectors, no network.
# Copies this repo into a temp dir, simulates two overlapping runs, a protected main branch,
# recovery from the fallback branch, and a code update from the template. Exits 1 on any failure.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
cd "$T"
export GIT_CONFIG_PARAMETERS="'push.negotiate=false' 'user.name=selftest' 'user.email=selftest@example.invalid' 'init.defaultBranch=main' 'advice.detachedHead=false'"
git init -q --bare remote.git; git init -q --bare upstream.git
mkdir work; (cd "$SRC" && git ls-files -z 2>/dev/null | tar --null -T - -cf - 2>/dev/null || tar --exclude=.git -cf - .) | (cd work && tar -xf -)
# fall back to a plain copy when not a git checkout
[ -f work/CLAUDE.md ] || cp -r "$SRC"/. work/ && rm -rf work/.git
(cd work && git init -q -b main && git add -A && git commit -qm init && git remote add origin ../remote.git && git push -q origin main && git push -q ../upstream.git main)
fail() { echo "SELFTEST FAILED: $*" >&2; exit 1; }
q() { python3 -I scripts/queue.py "$@"; }

echo "[1] first run adds item 1"
(cd work && eval "$(bash scripts/run-start.sh triage 2>/dev/null)" && q add slack_reply ack "reply: thanks" source=s1 >/dev/null && echo "# $RUN_ID" > state/runs/$RUN_ID.md && bash scripts/run-end.sh "triage 1" 2>/dev/null)
echo "[2] run A starts (stale base), run B closes item 1 and adds item 2, run A adds its own item 2"
(cd work && eval "$(bash scripts/run-start.sh proactive 2>/dev/null)" && echo "$RUN_ID" > ../a.runid)
git clone -q -b main remote.git b
(cd b && eval "$(bash scripts/run-start.sh approvals 2>/dev/null)" && q close 1 posted >/dev/null && q add email_reply pointer "email: send link" gmail_draft_id=d1 >/dev/null && echo "# $RUN_ID" > state/runs/$RUN_ID.md && bash scripts/run-end.sh "approvals" 2>/dev/null)
(cd work && RUN_ID=$(cat ../a.runid) && q add proactive fyi "draft: agenda" >/dev/null && echo "# $RUN_ID" > state/runs/$RUN_ID.md && bash scripts/run-end.sh "proactive" 2>/dev/null)
git clone -q -b main remote.git check
(cd check && bash scripts/validate-state.sh >/dev/null 2>&1 || fail "merged state invalid"
  [ "$(q list | wc -l)" = 3 ] || fail "expected 3 items after merge, got $(q list | wc -l)"
  q list | grep -q '"id": 1.*"status": "posted"' || fail "item 1 should be posted"
  q list | grep -q '"id": 2.*"label": "email: send link"' || fail "remote item should keep id 2"
  q list | grep -q '"id": 3.*"renumbered_from": 2' || fail "local item should be renumbered to 3"
  [ "$(ls state/runs/*.md | wc -l)" = 3 ] || fail "expected 3 run notes")
echo "[3] protected main parks state on the fallback branch"
printf '#!/bin/sh\nwhile read o n r; do [ "$r" = refs/heads/main ] && exit 1; done; exit 0\n' > remote.git/hooks/pre-receive; chmod +x remote.git/hooks/pre-receive
git clone -q -b main remote.git c
(cd c && eval "$(bash scripts/run-start.sh brief 2>/dev/null)" && q add note fyi "needs you" >/dev/null && echo "# $RUN_ID" > state/runs/$RUN_ID.md && bash scripts/run-end.sh "brief" 2>/dev/null) || fail "run-end should succeed via fallback"
git -C remote.git rev-parse -q --verify agent-state >/dev/null || fail "fallback branch missing"
echo "[4] next run recovers the fallback branch into main"
rm remote.git/hooks/pre-receive
git clone -q -b main remote.git d
(cd d && eval "$(bash scripts/run-start.sh triage 2>/dev/null)" && [ "$(q list | wc -l)" = 4 ] || fail "expected 4 items after recovery"
  q set 3 renumbered_from= >/dev/null && q list | grep -q renumbered_from && fail "renumbered_from should be removed" || true
  echo "# $RUN_ID" > state/runs/$RUN_ID.md && bash scripts/run-end.sh "triage 2" 2>/dev/null)
git -C remote.git rev-parse -q --verify agent-state >/dev/null && fail "fallback branch should be deleted after recovery" || true
echo "[5] template code update merges without touching state"
git clone -q -b main upstream.git up && (cd up && echo "# upstream change" >> README.md && git commit -qam "upstream change" && git push -q)
(cd d && sed -i 's|^  upstream_remote: ""|  upstream_remote: "../upstream.git"|' state/config.yaml && git commit -qam "set upstream" && git push -q origin main
  eval "$(bash scripts/run-start.sh triage 2>/dev/null)"; tail -1 README.md | grep -q "upstream change" || fail "upstream change not merged"
  [ "$(q list | wc -l)" = 4 ] || fail "state changed by upstream merge")
echo "[6] validator rejects content fields and conflict markers"
(cd d && python3 - <<'PY'
import json; q=json.load(open("state/queue.json")); q["items"][0]["draft_text"]="hello"; json.dump(q,open("state/queue.json","w"))
PY
  bash scripts/validate-state.sh >/dev/null 2>&1 && fail "validator accepted a content field" || true
  git checkout -q -- state/queue.json; printf '<<<<<<< HEAD\nx\n=======\ny\n>>>>>>> other\n' >> state/people.md
  bash scripts/validate-state.sh >/dev/null 2>&1 && fail "validator accepted conflict markers" || true
  git checkout -q -- state/people.md)
echo "SELFTEST OK"
