---
name: proactive
description: Read the owner's notes, to-do docs and recent 1:1 notes, find small tasks the agent can attempt (a first draft of a doc, a summary, an agenda, a status roll-up, a researched answer), do them without touching shared documents, and leave results in the review queue and the task log. Body of the daily proactive scheduled task.
argument-hint: "[--max N] [--only <doc id>]"
---

# /proactive

Run inside the run protocol. Cap: `--max` or `triage.max_proactive_tasks_per_run`.

## Find candidate tasks

Read every doc in `triage.drive.notes_docs` and every doc in `triage.drive.notes_folders` modified since `seen.drive[<id>]` (or the last 7 days on the first run), with Drive `read_file_content`. Also `search_files` for docs they own modified in the last 2 days. Look for:
- Unchecked checkboxes or lines starting with TODO, Action, AI (action item), Follow up, Next, "I'll", "I need to", "Draft", "Write up", "Send", "Summarise".
- Lines that mention them by name or handle in someone else's action list.
- Meeting notes with an "actions" or "next steps" section where an item is theirs.
- Open questions in their notes ("why did X happen", "what is the status of Y") that research across Slack and Drive could answer.

Also take the last 24 hours of their own Slack messages (`from:<@OWNER_ID>`) and look for promises: "I'll write up", "let me put together", "I'll send a summary".

Dedupe against `state/queue.json` and `state/ledger.jsonl` by source link plus a normalised label. Do not re-attempt something they skipped.

## Pick

Choose up to the cap, preferring tasks that are (a) clearly theirs, (b) producible as a document or a message draft, (c) answerable from the data you can reach, (d) due soon. Skip anything that would require sending, scheduling, approving, spending, deciding, or that touches people topics.

## Do

Allowed outputs only:
- A new Google Doc named `Draft: <task>` created with Drive `create_file` in the folder named `Agent drafts` (create it on first use at the root of their Drive). Never edit their existing documents or shared documents; put a proposed insertion in the draft doc with a note on where it would go.
- A Slack reply draft, handled through `/draft` and the review queue like any other draft.
- A researched answer written into the draft doc with links to every source.

Each result starts with a two-line header: what the task was and where you found it (link), then the work. Keep the writing in their docs register from the voice profile.

## Leave for review

Post `templates/proactive-result.md` to the review queue for each result and record the item: `python3 -I scripts/queue.py add proactive <category> "<label>" source=<notes doc link> draft_ref=<draft doc url> audience_kind=team`. Append a task log row. Update `seen.drive` watermarks. Write the run note, including the candidates you saw but did not attempt and why, in one line each.
