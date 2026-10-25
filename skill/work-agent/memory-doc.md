# Shape of the "Work agent memory" doc

Setup creates the doc with exactly these headings. Every run keeps them. The owner can edit anything in it; their edits win. No message text, email text or draft text goes in here.

```
Work agent memory
(Read and rewritten by the work agent. Edit freely. Do not share.)

## Settings
Name: <how they want to be addressed>
Slack user id: <U...>
Slack handle: <@...>
Mention search: userid | handle
Review DM channel id: <D...>
Email: <address>
Timezone: <IANA, e.g. America/Los_Angeles>
Work hours: 09:00-18:00 Mon-Fri
Max drafts per check-in: 12
Max note tasks per day: 3
Expire drafts after hours: 72
Disclosure suffix: <empty, or e.g. "(drafted with AI)">
Notes docs: <links to their running notes, 1:1 docs, to-do docs>
Notes folders: <links>
Agent drafts folder: <link, created on first use>
Auto-post: off

## Approve words
approve, approved, send, yes, ship, lgtm, 👍, ✅
Skip words: skip, no, reject, drop, ❌, 👎
Edit prefix: edit:

## Ignore
Channels: <ids and names>
Senders: noreply@, no-reply@, calendar-notification@, <...>
Subjects matching: [JIRA], Automatic reply

## Rules
(Their standing instructions, each with the date it was added.)
Always theirs (never draft):
Always draft:
Ignore:
Other:

## Style
Status: NOT BUILT | BUILT <date>
(How they write, by medium and audience: Slack, email, memos and docs, presentations, anything else. Free-form; include excerpts of their own writing and examples where useful.)

## References
(An index of their best pieces, linked, each with a quick description of what it is and what it shows about how they write.)

## People
(One line each: name · Slack id · role or team · relationship · drafting note)

## Projects
(One line each: name · status · links · who · what they want from it)

## Feedback
(One line per edit or skip on a draft: date · #id · category · kind of change, e.g. shorter, less formal, different answer. No quotes. Keep the last 40.)

## Run state
Next item number: 1
Last check-in: <ISO time>
Slack checked up to: <ISO time>
Email checked up to: <ISO time>
Notes checked up to: <ISO time>
Last note tasks run: <date>
Last brief sent: <date>
Known DM channels: <ids>

## Recent log
(Newest first, last 14 days: date · #id · type · category · short generic label · status · link to review message)
```
