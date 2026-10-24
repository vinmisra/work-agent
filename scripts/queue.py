#!/usr/bin/env python3
"""Small helper for state/queue.json. Run with: python3 -I scripts/queue.py <cmd> [args]

Commands
  add  <type> <category> "<label>" key=value ...   -> prints the new id
  set  <id> key=value ...                          -> update fields (status, review_ts, ...)
  close <id> <status>                              -> sets status and closed_at
  list [status]                                    -> prints items as JSON lines
  expire <hours>                                   -> marks pending_review older than N hours as expired, prints ids
Allowed keys: type category label status created_at closed_at source review_ref draft_ref gmail_draft_id target
              approval audience_kind autopost_eligible notes_ref session_url renumbered_from
Any key that could hold content (text, body, subject, message, draft_text) is rejected.
"""
import json, sys, datetime, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
P = os.path.join(ROOT, "state", "queue.json")
ALLOWED = {"type","category","label","status","created_at","closed_at","source","review_ref","draft_ref",
           "gmail_draft_id","target","approval","audience_kind","autopost_eligible","notes_ref","session_url","renumbered_from"}
FORBID = {"text","body","subject","message","draft_text","draft","content"}
def now(): return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
def load(): return json.load(open(P))
def save(q):
    json.dump(q, open(P,"w"), indent=2); open(P,"a").write("\n")
def kv(args):
    out = {}
    for a in args:
        if "=" not in a: raise SystemExit(f"bad arg {a!r}, expected key=value")
        k, v = a.split("=",1)
        if k in FORBID or k not in ALLOWED: raise SystemExit(f"key {k!r} not allowed in state")
        if v in ("true","false"): v = (v == "true")
        out[k] = None if v == "" else v   # key=  removes the field
    return out
def main(argv):
    if not argv: print(__doc__); return 2
    cmd, args = argv[0], argv[1:]
    q = load()
    if cmd == "add":
        typ, cat, label, rest = args[0], args[1], args[2], args[3:]
        if len(label) > 80: raise SystemExit("label must be <= 80 chars")
        it = {"id": q["next_id"], "type": typ, "category": cat, "label": label,
              "status": "pending_review", "created_at": now()}
        it.update(kv(rest)); q["next_id"] += 1; q["items"].append(it); save(q); print(it["id"])
    elif cmd == "set":
        i = int(args[0]); upd = kv(args[1:])
        for it in q["items"]:
            if it["id"] == i:
                for k, v in upd.items():
                    if v is None: it.pop(k, None)
                    else: it[k] = v
                save(q); print("ok"); return 0
        raise SystemExit(f"no item {i}")
    elif cmd == "close":
        i, st = int(args[0]), args[1]
        for it in q["items"]:
            if it["id"] == i: it["status"] = st; it["closed_at"] = now(); save(q); print("ok"); return 0
        raise SystemExit(f"no item {i}")
    elif cmd == "list":
        st = args[0] if args else None
        for it in q["items"]:
            if st is None or it["status"] == st: print(json.dumps(it))
    elif cmd == "expire":
        hours = float(args[0]); t = datetime.datetime.now(datetime.timezone.utc)
        for it in q["items"]:
            if it["status"] == "pending_review":
                age = t - datetime.datetime.fromisoformat(it["created_at"].replace("Z","+00:00"))
                if age.total_seconds() > hours*3600:
                    it["status"] = "expired"; it["closed_at"] = now(); print(it["id"])
        save(q)
    else:
        print(__doc__); return 2
    return 0
if __name__ == "__main__": sys.exit(main(sys.argv[1:]))
