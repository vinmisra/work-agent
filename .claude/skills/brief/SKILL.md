---
name: brief
description: Compose and deliver the daily brief: what the agent did, what is waiting on the owner, what it could not do, and tomorrow's calendar. Posts to the review queue and appends to the task log doc. Body of the end-of-day scheduled task; also usable on demand.
argument-hint: "[--since <ISO time>]"
---

# /brief

Run inside the run protocol. Start with `/approvals` so the brief reflects their latest decisions.

Gather from `state/queue.json`, `state/ledger.jsonl` and today's files in `state/runs/`:
- **Waiting on you**: items `pending_review`, oldest first, with age and the review-thread link. Include must-handle notes posted today (type `note`).
- **Done today**: items closed today with outcome (posted, draft in Gmail, done, expired, rejected).
- **Drafted, not yet reviewed**: same as waiting but created today; keep the section only if it adds information, otherwise merge into waiting.
- **Could not do**: every "Could not do" line from today's run notes, deduplicated: missing connectors, failed pushes, searches that found nothing, items skipped for lack of context.
- **Tomorrow**: if Calendar is available, `list_events` for the next working day: first meeting time, number of meetings, any meeting whose title or attendees match a waiting item. If not available, say "calendar not connected".

Fill `templates/daily-brief.md`. Keep it under 40 lines. Post it to the review queue with `slack_send_message`. Append a dated "Brief" row to the task log doc. If `brief.deliver_to` names a different channel, post there as well.

Housekeeping in the same run: items `pending_review` older than `review_queue.expire_after_hours` were expired by triage; mention them under Waiting with "(expired, reply approve to revive)". Reviving means re-opening the item with status `pending_review`.

Write the run note. The routine prompt runs `run-end.sh`.
