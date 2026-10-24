#!/usr/bin/env python3
"""Three-way semantic merge for state/queue.json and state/seen.json.
Git merge driver usage (configured by scripts/run-start.sh):
    python3 -I scripts/merge-state.py %O %A %B     # base ours theirs; writes result to %A
Exit 0 on success, 1 when the files cannot be merged (git then marks a conflict).
"""
import json, sys

RANK = {"pending_review": 0, "approved": 1, "blocked": 1, "draft_in_gmail": 2,
        "posted": 3, "done": 3, "rejected": 3, "expired": 3}

def load(p):
    try:
        with open(p) as f:
            txt = f.read()
        return json.loads(txt) if txt.strip() else {}
    except Exception:
        return None

def merge_item(base, ours, theirs):
    base = base or {}
    out = dict(base)
    keys = set(base) | set(ours) | set(theirs)
    for k in keys:
        b, o, t = base.get(k), ours.get(k), theirs.get(k)
        if o == t: out[k] = o
        elif o == b: out[k] = t
        elif t == b: out[k] = o
        elif k == "status":
            out[k] = o if RANK.get(o, 0) >= RANK.get(t, 0) else t
        else:
            # both changed differently: keep the one that goes with the winning status
            out[k] = o if RANK.get(ours.get("status"), 0) >= RANK.get(theirs.get("status"), 0) else t
        if out.get(k) is None and k in out: del out[k]
    return out

def merge_queue(base, ours, theirs):
    b = {i["id"]: i for i in base.get("items", [])}
    o = {i["id"]: i for i in ours.get("items", [])}
    t = {i["id"]: i for i in theirs.get("items", [])}
    items, renumber = [], []
    for i in sorted(set(b) | set(o) | set(t)):
        if i in o and i in t:
            if i in b or same_item(o[i], t[i]):
                items.append(merge_item(b.get(i), o[i], t[i]))
            else:
                # Both sides allocated the same new id for different items. The remote
                # (theirs) keeps the id because its review message is already out; ours is renumbered.
                items.append(t[i]); renumber.append(o[i])
        elif i in o:
            if i not in b: items.append(o[i])          # added by us
            # else: removed by them (moved to ledger) -> drop
        elif i in t:
            if i not in b: items.append(t[i])          # added by them
    next_id = max(ours.get("next_id", 1), theirs.get("next_id", 1), base.get("next_id", 1),
                  (max((it["id"] for it in items), default=0) + 1))
    for it in renumber:
        it = dict(it); it["renumbered_from"] = it["id"]; it["id"] = next_id; next_id += 1; items.append(it)
    out = dict(ours)
    out["_schema"] = ours.get("_schema") or theirs.get("_schema")
    out["next_id"] = next_id
    out["items"] = items
    return out

def same_item(a, b):
    keys = ("created_at", "source", "label", "type", "review_ref")
    return all(a.get(k) == b.get(k) for k in keys)

def later(a, b):
    if a is None: return b
    if b is None: return a
    try: return a if float(a) >= float(b) else b
    except (TypeError, ValueError): return a if str(a) >= str(b) else b

def merge_seen(base, ours, theirs):
    out = dict(ours)
    for section in ("slack", "drive", "last_run"):
        m = dict(base.get(section, {}))
        for src in (ours.get(section, {}), theirs.get(section, {})):
            for k, v in src.items(): m[k] = later(m.get(k), v) if k in m else v
        out[section] = m
    g = dict(ours.get("gmail", {}))
    g["newest_processed"] = later(ours.get("gmail", {}).get("newest_processed"), theirs.get("gmail", {}).get("newest_processed"))
    out["gmail"] = g
    out["_schema"] = ours.get("_schema") or theirs.get("_schema")
    return out

def main():
    base_p, ours_p, theirs_p = sys.argv[1:4]
    base, ours, theirs = load(base_p), load(ours_p), load(theirs_p)
    if ours is None or theirs is None: return 1
    base = base or {}
    schema = ours.get("_schema") or theirs.get("_schema") or ""
    if schema.endswith("/queue/v1"): out = merge_queue(base, ours, theirs)
    elif schema.endswith("/seen/v1"): out = merge_seen(base, ours, theirs)
    else: return 1
    with open(ours_p, "w") as f:
        json.dump(out, f, indent=2); f.write("\n")
    return 0

if __name__ == "__main__":
    sys.exit(main())
