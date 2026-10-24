---
name: draft
description: Write one reply as the owner, in their voice, for a Slack thread or email, with the context gathered first. Used by /triage for each draftable item and directly when they ask "draft a reply to X about Y".
argument-hint: "<slack permalink | gmail thread id | description of what to reply to>"
---

# /draft

Precondition: `state/voice-profile.md` is BUILT. Otherwise say so and stop.

## Gather context (before writing a word)

1. Read the whole thread (`slack_read_thread` or Gmail `get_thread`), not just the last message.
2. Identify the asker in `state/people.md`; note audience kind and any drafting note.
3. If the message asks a factual question, find the answer: search Slack (`slack_search_public_and_private` with the key terms, `in:` the same channel first), then Drive (`search_files` with `fullText contains`), then `state/projects.md`. Keep the source link. If you cannot find it, do not draft; sort the item as must-handle with "could not find the answer".
4. If it is a status ask, look at the latest activity in the relevant channel or doc and summarise what is actually there.
5. If it is scheduling and Calendar is available, check `list_events` for the proposed time. Never commit them to a time; propose or ask.

## Write

- As them. First person. Their register for this audience and channel (Slack DM vs channel vs email differ; see the profile).
- Length: match the thread. Most Slack replies they write are one to three sentences. Email: their usual email length.
- Answer first, then the one supporting fact or link. No preamble, no "great question", no apology unless they would apologise.
- Do not promise dates, budgets, headcount or decisions. If the natural reply needs one, write the reply around it ("let me confirm the date and come back to you") and flag it in the review message context line.
- Do not mention anyone who is not in the thread by name unless the reply is pointing the asker to that person and it is obviously appropriate.
- No signature, no AI disclosure (the config suffix is appended at posting time, not in the draft).
- If two reasonable replies exist (yes vs no, now vs later), draft the one their history suggests and say in the context line what the other would be.

## Deliver

Return: the draft text, a one-line context line for the review message ("asking for the launch date; I avoided committing"), the category, the audience kind, and the source links used. The caller posts it.
