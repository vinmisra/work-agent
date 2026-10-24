# Architecture

## Pieces

```
claude.ai (the owner's work account)
  scheduled tasks ──► cloud session (ephemeral container)
                         │  clones the owner's agent repo (GitHub)
                         │  reads CLAUDE.md, .claude/rules, .claude/skills, routines/, state/
                         │  uses connectors: Slack, Gmail, Google Drive, Google Calendar
                         │  writes: review queue (Slack), Gmail Drafts, "Agent drafts" (Drive), task log doc (Drive)
                         └─ pushes state/ back to main

owner's laptop (once)──► claude CLI: /setup, /voice, /schedule
owner, any time  ──► claude.ai/code session on the repo, or a run's session from the task History
owner, in Slack  ──► replies in review threads: approve / edit: / skip
```

## Why these choices

- **Repo as memory.** Cloud runs are ephemeral; the only durable, versioned, model-readable store that needs no server is the repo. Each run pulls at start and pushes at end. Conflicts are rare because runs are hourly and state edits are small; `run-end.sh` rebases and retries.
- **Short task prompts, long routine files.** The scheduled task on claude.ai only names the routine file. Behaviour changes ship by commit; no one has to edit tasks on claude.ai.
- **Skills under `.claude/skills/`, not a plugin.** Cloud runs do not load plugins; they load skills committed in the repo. The plugin manifest points at the same directory so the one-time laptop install gets `/work-agent:setup` without duplicating files.
- **Approve-to-send through Slack threads.** The Slack connector can send messages and read threads but exposes no reaction reads, so approval is a thread reply, not a reaction. The owner's DM to themselves is the default queue because it needs no channel creation and nobody else can see it.
- **Email drafts in Gmail.** The connector can create drafts; sending is denied in `.claude/settings.json`. The owner sends from Gmail, which keeps the email in their sent folder with their client's signature and threading.
- **Nothing on the maintainer's machines.** The maintainer keeps the code in a template repo. The owner's instance is their own private repo; `/update` merges the maintainer's changes without touching `state/`.
- **State holds pointers, not content.** See `privacy-and-data-boundaries.md`. The validator refuses content-shaped fields.
- **Overlapping runs cannot corrupt state.** `state/queue.json` and `state/seen.json` merge semantically (`scripts/merge-state.py`, wired through `.gitattributes`); append-only files use git's union merge; a colliding id is renumbered rather than fused; a push that `main` rejects is parked on `agent-state` and merged back by the next run. `scripts/selftest.sh` exercises all of this with no connectors.

## Guardrails in order of strength

1. `.claude/settings.json` deny rules: email send, calendar writes, Drive share and trash, force pushes, and web fetch and search (runs have no reason to reach the open web, which also closes the obvious exfiltration path). These are enforced by the harness, not by the prompt.
2. `.claude/rules/*.md`: always-on instructions for privacy, approval and state.
3. `scripts/validate-state.sh`: refuses content fields, credentials, malformed state. Runs at start and end of every run and in CI.
4. `state/config.yaml` switches: auto-post off, categories that can never be auto-posted, ignore lists.
5. `documents/ai-policy-check.md`: the run reads the Decision section before any auto-post.

## Failure modes and what happens

| Failure | Behaviour |
|---------|-----------|
| A connector is missing in a run | That part is skipped, recorded under "Could not do" in the run note and the brief. No invented data. |
| Push fails after retries | State is committed in the session only. The run note says PUSH FAILED; the brief repeats it. The next run redoes the lost work (idempotent by watermark and source link, so no double posts: approvals check the review thread for a "Posted:" reply before posting). |
| Auto mode unavailable | The run pauses at the first tool prompt; the owner answers it from the task's History page. `/checklist` row 11. |
| The owner never reviews a draft | Expired after `expire_after_hours`, listed in the brief, revivable with "approve". |
| Voice profile not built | Triage still runs; nothing is drafted; must-handle notes say why. |
| GitHub connection lost for 72 hours | claude.ai disables the tasks. Reconnect at claude.ai/connect-github and re-enable them. |
