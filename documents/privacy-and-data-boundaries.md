# Privacy and data boundaries

This document is the contract for where data may live. Every skill and routine prompt in this repo is written to obey it. If a rule here conflicts with anything else in the repo, this document wins.

## The parties

| Who | Role | What they touch |
|-----|------|-----------------|
| The owner | Owner and only operator | Everything. The agent runs under their work Claude, Slack and Google Workspace accounts. |
| The maintainer | Maintains the code in this repo | Code, prompts, skills, docs. Never company data, never company IT. |
| Anthropic cloud | Runs each routine in an ephemeral container | Whatever the connectors return during a run, inside the company's Claude org, under the org's data terms. |
| GitHub | Stores this repo | Code plus the small state files described below. |

## What may live where

**In Slack, Gmail, Drive (company systems):** everything substantive. Message bodies, draft replies, documents, the task log, the daily brief. This is where the agent writes its output.

**In this repo (`state/`):** settings, learned style descriptors, pointers and status. Concretely:

- `config.yaml`: the owner's ids, channel ids, switches.
- `queue.json`, `ledger.jsonl`: item ids, type, category, status, timestamps, and pointers (Slack permalinks and message timestamps, Gmail message and draft ids, Drive file ids). A short label of at most 80 characters that describes the item generically ("reply to teammate about launch date"). No message bodies, no draft text, no quotes.
- `seen.json`: watermarks (timestamps and ids).
- `voice-profile.md`: descriptions of how they write. Short excerpts of their own writing only if they approved including them during setup, and never excerpts of other people's messages.
- `people.md`, `projects.md`: names, roles, relationships, links. No content of conversations.
- `triage-rules.md`, `feedback.jsonl`: rules and the kind of edits they make ("shortened", "removed apology", "added a deadline"), not the text.
- `runs/`: per-run notes in the same pointer-and-label form.

**Never in this repo:** Slack message text, email bodies or subjects, document contents, draft text, attachments, customer or partner names from message content, anything from a channel marked confidential, credentials or tokens.

**On the maintainer's machines:** nothing from the company. The maintainer does not run the agent, does not hold the owner's credentials, and should not be a collaborator on a repo whose `state/` directory has been populated. See "Repo ownership" below.

**On the owner's laptop:** only during the one-time `/work-agent:setup`, which reads their local Claude Code and Codex history to build the voice profile. It writes descriptors to `state/voice-profile.md` and nothing else. After setup the CLI is dormant.

## Repo ownership

The spec says the maintainer maintains the repo. Because `state/` fills with pointers and labels derived from the owner's work, the recommended shape is:

1. The maintainer maintains a **template repo** (this one), public or private, containing code only. `state/` holds only the empty schemas.
2. The owner creates **their own private repo from the template** on their GitHub account (`gh repo create <name> --private --template <owner>/work-agent`). Their routines run against their repo. `/work-agent:update` pulls code changes from the template.
3. The maintainer is not a collaborator on the owner's repo.

If the owner prefers one repo for simplicity, it must be private and under their account, with the maintainer contributing by pull request from a fork. In either arrangement, the maintainer's access stops at the code.

## Posting on the owner's behalf

- Slack messages and Gmail drafts created by the agent are created through their connectors and therefore appear as the owner. Slack has no "sent by an assistant" marker.
- Until `posting.auto_post_enabled` is true in `config.yaml`, nothing is posted anywhere except the review queue (their own DM or private channel) and Gmail Drafts.
- Turning auto-post on is the owner's decision alone, taken after completing `documents/ai-policy-check.md`.

## Retention

- `queue.json` keeps closed items for 14 days, then the run moves them to `ledger.jsonl`.
- `runs/` notes older than 60 days are deleted by the brief routine.
- Nothing in the repo needs to be kept for the owner's work. Deleting the repo loses only settings and the learned voice profile.

## If the org blocks GitHub

Use `documents/fallback-google-docs.md`. The same rules apply: the "instructions" doc holds what this repo's prompts hold, the "state" doc holds what `state/` holds, both owned by the owner, shared with nobody.
