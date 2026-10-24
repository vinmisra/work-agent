---
name: approvals
description: Process the owner's decisions on queued drafts. Reads each pending item's review thread in Slack, applies approve / edit / skip, posts approved Slack replies to the original thread, updates Gmail drafts, records feedback, and closes items. Called at the start of /triage and usable on its own ("process approvals", "send 14").
argument-hint: "[item id ...]  (optional: act on these ids only; 'send 14' approves 14 without a thread reply)"
---

# /approvals

For each item with status `pending_review` in `state/queue.json` (or only the ids given):

1. `slack_read_thread` on the item's `review_ref` (queue channel and the review message timestamp). Consider only replies from the owner (`owner.slack_user_id`) newer than the item's `created_at`. Take the latest.
2. Interpret the reply:
   - Matches `review_queue.approve_words` (case-insensitive, whole message, punctuation ignored): **approve as-is**.
   - Starts with `review_queue.edit_prefix` ("edit:"), or is a reply longer than 40 characters that reads as a rewritten draft: **approve the edited text**. Record a feedback line (see 5) describing the kind of change.
   - Matches `reject_words`: **reject**.
   - Anything else (a question, a comment): reply in the thread with one short clarification or answer, and leave the item pending.
   - No reply: leave pending.
   - An explicit instruction from the owner in this session ("send 14", "skip 9") counts as a thread reply with the same meaning. Note `approval=session` on the item.
3. Act:
   - **Slack reply**: read the draft text from the review message (or use the edited text), append `posting.disclosure_suffix` if config sets one, and `slack_send_message` to the item's `target` channel in the original thread. If the tool cannot post into a thread, post in the channel and start with the quoted first line of the original so the context is clear. Then reply in the review thread: "Posted: <permalink>". Set status `posted`, `approval=reply:<ts>`.
   - **Email**: there is nothing to send. If approved, reply in the review thread "Draft is in Gmail; send it from there" and close as `draft_in_gmail`. If edited, update the Gmail draft (`create_draft` again as a reply in the same thread and note the new draft id; delete the old draft only if a delete-draft tool exists, otherwise tell them the old one is still there). If skipped, tell them to discard the draft in Gmail and close as `rejected`. Also check `list_drafts`: an email item whose draft id is no longer in Drafts was sent or discarded by them; close it as `done`.
   - **Proactive result**: approve means the artefact stands; close as `done`. Edit means redo per their notes in a new item that links the old one. Skip closes as `rejected`.
4. Close with `python3 -I scripts/queue.py close <id> <status>` and set `approval`.
5. Feedback: append a line to `state/feedback.jsonl` for every edit or rejection: `{"ts":..., "id":..., "category":..., "audience_kind":..., "outcome":"edited"|"rejected", "change_kinds":["shorter","less formal","removed hedge","added deadline","different answer", ...], "note": "<10 words max, no quotes from the text>"}`. If the same change kind appears five times in the last 30 days, say in the run note that `/voice --refresh` is due.
6. If the owner wrote a durable instruction in any thread ("always ignore X", "never draft for Y", "stop drafting status updates"), add it to `state/triage-rules.md` with the date and the review link, and confirm in the thread.
7. Update the task log doc rows for every item that changed status.
8. If an item carries `renumbered_from` (two overlapping runs allocated the same id and the merge renumbered this one), reply once in its review thread "This draft is now #<id>", then remove the field with `python3 -I scripts/queue.py set <id> renumbered_from=`.
