# Check-in

One pass: process their decisions on earlier drafts, look at what is new, draft what you can, and on the right runs also work through their notes and send the brief. This is what the scheduled task runs.

Start: find and read the memory doc (see SKILL.md). Note the current time in their timezone.

- Outside their work hours or days: do section 1 only, update the memory doc, finish.
- Otherwise do sections 1 to 4. Then section 5 if `Last note tasks run` is not today. Then section 6 if it is within 90 minutes of the end of their work hours, or later, and `Last brief sent` is not today.
- Finish with section 7. Always.

## 1. Approvals

Read the review DM (`slack_read_channel` on `Review DM channel id`) back to `Expire drafts after hours` ago. For each `[#<id>]` message without a closing 🤖 reply in its thread (`slack_read_thread`), take the owner's latest reply that does not start with 🤖:

- An approve word (whole reply, case and punctuation ignored): approve as-is.
- Starts with `edit:`, or is a longer reply that reads as a rewritten draft: approve the edited text.
- A skip word: skip.
- A question or comment: answer it in one 🤖 reply and leave the draft pending.
- No reply and older than `Expire drafts after hours`: reply `🤖 Expired. Reply approve to revive.` A later approve on an expired draft revives it.
- A chat instruction ("send 14", "skip 9") counts the same as a thread reply.

Then act:

- **Slack draft approved:** post the text (from the review message, or their edit) with `slack_send_message` to the original channel, in the original thread, plus the disclosure suffix if set. Nothing else added. Reply `🤖 Posted: <permalink>`. If the original thread cannot be resolved, do not guess: reply `🤖 Couldn't find the original thread; post it yourself: <link>`.
- **Email:** approved means nothing to do; reply `🤖 Gmail draft is ready; send it from Gmail.` Edited: create a new Gmail draft in the same thread with the edited text, reply `🤖 Gmail draft updated.` and tell them to delete the old draft if you cannot. Skipped: reply `🤖 Skipped. Discard the draft in Gmail.`
- **Note task:** approved closes it; edited means redo it per their note as a new item; skipped closes it.
- **Skipped Slack draft:** reply `🤖 Skipped.`

For every edit or skip, add a line to Feedback. If they wrote a standing instruction ("always ignore X", "never draft for Y"), add it to Rules with today's date and confirm with `🤖 Got it: <rule>, saved.` When their edits show you something about how they write, update Style and References.

## 2. Gather new items

From `Slack checked up to` and `Email checked up to` (on the very first check-in, the last 24 hours). Skip ignored channels and senders, and anything they wrote themselves.

- **Mentions:** `slack_search_public_and_private` with `<@USERID>` or `@handle` (per `Mention search`) and `after:<date>`, paging until older than the watermark.
- **DMs and group DMs:** `slack_read_channel` for each id in `Known DM channels`, plus new ones found by searching `to:<@USERID> after:<date>`. Add new DM ids to `Known DM channels`.
- **Threads they are in:** search `from:<@USERID>` over the last 3 days, read those threads, keep replies newer than the watermark that are not theirs.
- **Email:** Gmail `search_threads` with `in:inbox -from:me after:<date>`, then read each thread. Skip threads whose newest message is theirs.

One item per thread. If they already replied after the newest message, it is not an item.

## 3. Sort

Their Rules win. Then:

**Needs you** (no draft): performance, pay, hiring, firing, promotions, personal matters, conflict between people; commitments of dates, budget, headcount, scope or spend; executive or external audiences unless it is a pure acknowledgement; decisions only they can make; disagreements, escalations, incidents, legal, security, policy; anything emotionally charged or where you lack the context to answer confidently.

**Draft:** questions answerable from Slack, their docs or Projects (link the source); status asks about work visible in Slack or Drive; acknowledgements, thanks, "will look"; scheduling replies that do not promise an unconfirmed time; requests for a doc, link or the right person; routine reviews where their answer is predictable from history.

**Ignore:** bots and notifications, newsletters, chatter that does not need them, things someone else already answered, duplicates.

Give every item a category: `ack`, `scheduling`, `status`, `answer`, `pointer`, `review`, `decision`, `people`, `commitment`, `external`, `exec`, `escalation`, `fyi`.

## 4. Draft and post

Skip drafting if Style is NOT BUILT; list those items under Needs you with "style guide not set up".

For each draftable item, up to `Max drafts per check-in`, most urgent first, follow **Draft** below. Give it the next item number (then increase `Next item number`). Post it to the review DM in the matching shape from `messages.md`. For email, create the Gmail draft as a reply in the original thread first, then post the email shape. Add a Recent log line.

Then, if any, post one Needs you message.

## 5. Note tasks (once a day, first check-in of the day)

Read each doc in `Notes docs`, and docs in `Notes folders` changed since `Notes checked up to` (first time: last 7 days). Also look at their own Slack messages from the last day for promises ("I'll write up", "let me put together").

Look for things that are clearly theirs and that you can produce as a document or a message draft: unchecked to-dos, action items with their name, "draft", "write up", "summarise", open questions that Slack and Drive could answer. Skip anything that needs sending, scheduling, approving, spending, deciding, or touches people topics. Skip anything already in Recent log, especially things they skipped.

Do up to `Max note tasks per day`. Results go in a new Google Doc named `Draft: <task>` in the `Agent drafts` folder (create the folder on first use and record its link), starting with two lines: what the task was and where you found it. Never edit their existing docs; if the result is an insertion, put it in the new doc with a note on where it would go. A message draft goes through **Draft** and the review DM instead. Post the note task shape for each. Set `Last note tasks run` to today.

## 6. Daily brief (once a day, end of day)

Compose the brief from the review DM and Recent log: what is waiting (oldest first, with age), what got done today, what you could not do today (missing connectors, failed doc updates, things you could not find), and tomorrow from Google Calendar `list_events` (or "calendar not connected"). Post it to the review DM in the shape from `messages.md`. Set `Last brief sent` to today.

## 7. Finish

Move watermarks to the newest item you processed (not to now). Trim Recent log to 14 days and Feedback to 40 lines. Add anyone new with a clear role to People. Keep Style and References current as you see more of their writing. Rewrite the memory doc. If anything failed, say so in one short 🤖 line in the review DM rather than staying silent.

## Draft

Understand the whole conversation and who is asking (People helps), and get the facts right: research Slack, Drive, Calendar and Projects as much as the reply needs, and link sources where useful. If you can't find what the answer depends on, don't guess; it goes under Needs you.

Write it in their style, using the Style section and References, and reading examples or researching more of their work as you need to.

Never commit them to dates, budgets, headcount, decisions or meeting times; write around it and say so in the Context line. If there is a real fork in how to answer, draft the one you think they'd pick and name the other in the Context line.

## Status

Without changing anything: list pending drafts from the review DM (id, label, age, link), what the last check-in and brief did per Run state and Recent log, and anything broken (missing connectors, Style NOT BUILT). End with the one thing that would help most.
