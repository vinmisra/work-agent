---
name: triage
description: One triage pass over the owner's new Slack mentions, DMs, threads and email since the last watermark. Processes pending approvals first, sorts each new item into must-handle / draft / ignore, drafts replies in their voice for the draftable ones, posts them to the review queue, and updates state. This is the body of the hourly scheduled task; also usable interactively.
argument-hint: "[--max-drafts N] [--lookback-hours N] [--dry-run]"
---

# /triage

Run inside the run protocol from `CLAUDE.md` (the routine prompt does `run-start.sh`; interactively, do it yourself). Read config, voice profile, people, projects and triage rules first.

## 0. Approvals first

Run `/approvals`. Items they approved since the last run get posted before anything new is drafted.

## 1. Gather new items

Watermarks are in `state/seen.json`. On the first run, use `triage.lookback_hours`. Work in their timezone.

**Slack mentions.** `slack_search_public_and_private` with the mention form recorded in `triage.slack.mention_query` (`<@OWNER_ID>` or `@handle`) plus `after:<watermark date>`. Page until results are older than the watermark. Skip channels in `channels_ignore`. Skip messages they wrote.

**Slack DMs and group DMs.** For each DM channel id listed in `seen.slack` (seeded by past runs) and any new DM found by searching `to:<@OWNER_ID> after:<date>` and `is:dm after:<date>` (use whichever the connector accepts), `slack_read_channel` and keep messages newer than that channel's watermark.

**Threads they are in.** Search `from:<@OWNER_ID> after:<watermark minus 3 days>` to find threads they have posted in recently; `slack_read_thread` each and keep replies newer than the thread's watermark that are not theirs.

**Channels always.** `slack_read_channel` for each id in `triage.slack.channels_always`.

**Email.** Gmail `search_threads` with `in:inbox newer_than:<hours>h -from:me` and the ignore rules from config; `get_thread` for each. Skip threads whose newest message is theirs.

Dedupe: one item per thread. If they already replied after the newest message, it is done, not an item.

## 2. Sort

Apply, in this order: `state/triage-rules.md` (their explicit rules win), then these defaults.

**The owner must handle it** (no draft; list it for them):
- People topics: performance, compensation, hiring or firing, promotions, personal matters, conflict between people.
- Commitments: dates, budgets, headcount, scope promises, approvals of spend, anything that binds them or their team.
- Executive or external audience, unless the item is a pure acknowledgement.
- Decisions they alone can make, disagreements, escalations, incidents, legal, security, policy.
- Anything where you lack the context to answer confidently, or the thread is emotionally charged.

**The agent can draft:**
- Questions answerable from Slack history, their docs, or `state/projects.md` (link the source).
- Status asks about work they or their team owns, when the status is visible in Slack or Drive.
- Acknowledgements, thanks, "got it, will look", scheduling replies that do not promise a date they have not confirmed.
- Requests for a document, link, or pointer to the right person.
- Routine review requests where their usual answer is predictable from history.

**Ignore:** bots and automated notifications, newsletters, channel chatter that does not need them, items already answered by someone else, duplicates, anything in the ignore lists.

Assign a category to every item: `ack`, `scheduling`, `status_update`, `question_answer`, `pointer`, `review`, `decision_needed`, `people_topic`, `commitment`, `external`, `executive`, `escalation`, `fyi`, `noise`. Assign `audience_kind`: `team`, `manager`, `xfn`, `external`, `exec`.

## 3. Draft

For each draftable item, up to `--max-drafts` or `triage.max_drafts_per_run`, in order of apparent urgency: follow `/draft`. Skip drafting entirely if the voice profile is NOT BUILT; list those items as must-handle with the reason "voice profile not built".

## 4. Post to the review queue

One Slack message per draft in the review queue (`review_queue.channel_id`) using `templates/review-message.md`. For email drafts: create the Gmail draft with `create_draft` as a reply in the original thread (if `create_draft` is unavailable, put the full text in the review message instead), then post `templates/review-message-email.md`. Record each item with `python3 -I scripts/queue.py add <type> <category> "<label>" source=<permalink or thread id> target=<channel:thread_ts> review_ref=<queue channel:ts> audience_kind=<kind> autopost_eligible=<true|false>` and `gmail_draft_id=<id>` where relevant.

Then one grouped message, only if there are must-handle items: "Needs you (N)" with one line each: who, where, what kind, link. These are logged as `type=note` items with status `done` so the brief can count them, and listed in the task log doc.

Append one row per new item to the task log doc (Drive `update_file`, newest first, below the table header).

With `--dry-run`, do everything except posting, creating drafts, and updating the doc; print what would have been posted.

## 5. Auto-post (normally off)

Only if `posting.auto_post_enabled` is true AND the item's category is in `posting.auto_post_categories` AND not in `posting.never_auto_post` AND `audience_kind` is `team` AND `documents/ai-policy-check.md` marks auto-posting "Allowed" or "Allowed with marker": post the reply directly to the original thread, mark the item `posted` with `approval=auto`, and still post a copy to the review queue prefixed "Auto-posted". Otherwise approve-to-send.

## 6. Finish

Expire old items: `python3 -I scripts/queue.py expire <review_queue.expire_after_hours>`. Update every watermark in `state/seen.json` to the newest item processed (not to now, so nothing is skipped if the search missed something). Update `state/people.md` if you met someone new with a clear role. Write the run note. The routine prompt runs `run-end.sh`; interactively, run it yourself.
