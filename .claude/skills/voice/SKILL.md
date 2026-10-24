---
name: voice
description: Build or refresh state/voice-profile.md from the owner's own writing in Slack, Gmail, Drive, and local Claude Code, Codex and Claude.ai history. Produces style descriptors they review and approves. Use when the profile says NOT BUILT, when they ask to rebuild it, or when feedback.jsonl shows the same edit kind five times.
argument-hint: "[--refresh]  (merge new observations into the existing profile instead of rebuilding)"
---

# /voice

Goal: a profile that lets a drafter write as them, not about them. Descriptors, patterns, and vocabulary. Quotes of their own writing only if they approve "Approved excerpts" at the end; never quotes of anyone else.

## Sources (collect what exists, skip what does not, say which you used)

1. **Slack.** `slack_search_public_and_private` with `from:<@OWNER_ID>`, paging back until you have about 300 messages across channels, group DMs and DMs. Note the channel kind for each so you can separate registers.
2. **Gmail.** `search_threads` for `from:me newer_than:90d`, read the threads, keep only their messages. About 60 emails is enough.
3. **Drive.** `search_files` with `owner = 'me' and mimeType = 'application/vnd.google-apps.document' and modifiedTime > <180 days ago>`. Read up to 10 documents they authored. Docs register only.
4. **Local Claude Code history** (laptop only): user turns in `~/.claude/history.jsonl` and `~/.claude/projects/*/*.jsonl` (lines with `"type":"user"`). Read with `python3 -I`, extract their text only, ignore tool results.
5. **Local Codex history** (laptop only): `~/.codex/sessions/**/*.jsonl`, user turns only, if the directory exists.
6. **Claude.ai export** (optional): ask if they have exported their data (Settings, Privacy, Export data). If they give a path to the zip or `conversations.json`, read only their `human` turns.

Never copy any of this raw material into the repo. Work in memory and write only the profile.

## Analysis

Separate three registers: Slack, email, docs. For each, work out:
- Typical length, sentence shape, punctuation, capitalisation, emoji and reaction habits, greetings and sign-offs.
- Vocabulary: phrases they reach for, words they avoid, how they hedge, how they say no, how they ask for things, how they give feedback.
- Audience shifts: team vs manager vs cross-functional vs external. Pull audience from `state/people.md` where possible.
- Structure habits in docs: headings, bullets, tables, how they open a doc, how they state decisions.
- What they care about: recurring themes, standards they enforce, things they push back on.

## Output

Rewrite `state/voice-profile.md` keeping its section headings. Replace the Status line with `Status: BUILT <date> from <sources used>`. Keep it under 250 lines. With `--refresh`, read `state/feedback.jsonl`, summarise what their edits have been correcting, and adjust the relevant sections rather than rebuilding.

Show them the profile section by section and ask for corrections. Then ask one question: "Include up to 10 short excerpts of your own messages as examples? They would live in the private repo." Only with an explicit yes, add them under "Approved excerpts", each under 200 characters, none containing another person's name or any customer, partner or confidential term.

Finish with `bash scripts/validate-state.sh`. The caller (usually `/setup`) commits.
