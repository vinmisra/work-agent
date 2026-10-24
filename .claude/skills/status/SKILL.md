---
name: status
description: Show what is waiting on the owner, what the agent did recently, the last run of each routine, and any problems, from state only (no connector calls). Use when the owner asks "what's waiting", "what did you do", "status".
---

# /status

Read `state/queue.json`, `state/seen.json.last_run`, and the three most recent files in `state/runs/`. Print:

1. Pending items: id, label, category, age, review link.
2. Last run time and outcome for triage, proactive, brief, approvals, and whether the last push succeeded (look for "PUSH FAILED" in the latest run note).
3. Counts for the last 7 days: drafted, posted, rejected, expired, must-handle notes.
4. Problems: missing connectors noted in run notes, voice profile NOT BUILT, policy check not completed, auto-post switches that are on.
5. The one or two things they could do that would help most (for example "reply to the 3 drafts older than a day", "fill in the policy check").

Offer `/approvals` to act on anything, and `/triage` to run a pass now.
