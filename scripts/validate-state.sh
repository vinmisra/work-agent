#!/usr/bin/env bash
# Validates the state directory. Exit 1 on any problem. Pure bash + python3 -I (stdlib only).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
fail=0
say() { printf '%s\n' "$*" >&2; }

for f in state/config.yaml state/queue.json state/seen.json state/voice-profile.md state/people.md state/projects.md state/triage-rules.md; do
  [ -f "$f" ] || { say "missing $f"; fail=1; }
done
[ -f state/ledger.jsonl ] || : > state/ledger.jsonl
[ -f state/feedback.jsonl ] || : > state/feedback.jsonl

python3 -I - <<'PY' || fail=1
import json, re, sys
errs = []
q = json.load(open("state/queue.json"))
if q.get("_schema") != "work-agent/queue/v1": errs.append("queue.json: bad _schema")
if not isinstance(q.get("next_id"), int) or q["next_id"] < 1: errs.append("queue.json: next_id must be a positive int")
ids = set()
allowed_status = {"pending_review","approved","posted","rejected","expired","blocked","done","draft_in_gmail"}
allowed_type = {"slack_reply","email_reply","proactive","note"}
for it in q.get("items", []):
    i = it.get("id")
    if not isinstance(i, int): errs.append(f"queue item without int id: {it}"); continue
    if i in ids: errs.append(f"duplicate id {i}")
    ids.add(i)
    if i >= q["next_id"]: errs.append(f"item {i} >= next_id")
    if it.get("status") not in allowed_status: errs.append(f"item {i}: bad status {it.get('status')}")
    if it.get("type") not in allowed_type: errs.append(f"item {i}: bad type {it.get('type')}")
    lab = it.get("label","")
    if len(lab) > 80: errs.append(f"item {i}: label longer than 80 chars")
    for k in ("draft_text","body","text","subject","message"):
        if k in it: errs.append(f"item {i}: field '{k}' is not allowed in state (content leak)")
s = json.load(open("state/seen.json"))
if s.get("_schema") != "work-agent/seen/v1": errs.append("seen.json: bad _schema")
for name in ("state/ledger.jsonl","state/feedback.jsonl"):
    for n, line in enumerate(open(name), 1):
        line = line.strip()
        if not line: continue
        try: json.loads(line)
        except Exception as e: errs.append(f"{name}:{n}: not JSON ({e})")
# yaml: minimal sanity without a yaml library
cfg = open("state/config.yaml").read()
for key in ("owner:","review_queue:","task_log:","posting:","triage:","brief:","runtime:"):
    if key not in cfg: errs.append(f"config.yaml: missing top-level key {key}")
if "\t" in cfg: errs.append("config.yaml: tabs are not allowed in YAML")
# conflict markers and credential sniff across state
pat = re.compile(r"(xox[abp]-[A-Za-z0-9-]+|ghp_[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|AIza[0-9A-Za-z_-]{30,})")
import glob
for f in glob.glob("state/**/*", recursive=True):
    try: txt = open(f, errors="ignore").read()
    except Exception: continue
    if pat.search(txt): errs.append(f"{f}: looks like it contains a credential")
    if re.search(r"^(<{7}|={7}|>{7})( |$)", txt, re.M): errs.append(f"{f}: contains merge conflict markers")
for e in errs: print("validate-state:", e, file=sys.stderr)
sys.exit(1 if errs else 0)
PY

if [ "$fail" -ne 0 ]; then say "validate-state: FAILED"; exit 1; fi
say "validate-state: ok"
