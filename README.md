# Work agent

A Claude Code agent that handles the reactive part of a manager's day under their own accounts: it triages Slack and email, drafts replies in their voice for their approval, takes a first crack at small tasks it finds in their notes, and sends a daily brief. It runs as scheduled cloud tasks on claude.ai against this repository, using the Slack, Gmail, Google Drive and Google Calendar connectors their org allows. Nothing runs on their laptop after setup and nothing runs on anyone else's machine.

Approve-to-send is the only mode until the owner decides otherwise. Email is never sent by the agent. State lives in `state/` as pointers and labels, never message content (see `documents/privacy-and-data-boundaries.md`).

## Install (the owner's laptop, once)

```
# 1. Make a private instance of this template under your GitHub account
git clone <template-url> work-agent && cd work-agent
git remote rename origin upstream
gh repo create work-agent --private --source=. --remote=origin --push

# 2. Optional: install the plugin so the commands work from any directory
claude plugin marketplace add ./
claude plugin install work-agent@work-agent

# 3. Set up
claude
/setup          # or /work-agent:setup
/schedule       # prints the three scheduled-task commands
```

Preconditions are in `documents/claude-connector-checklist.md`. If the org blocks GitHub, see `documents/fallback-google-docs.md`; if they cannot run the CLI, see `documents/fallback-web-only-install.md`.

## Layout

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Standing instructions loaded in every run and session |
| `.claude/rules/` | Always-on privacy, approval and state rules |
| `.claude/skills/` | `setup`, `voice`, `triage`, `approvals`, `draft`, `proactive`, `brief`, `status`, `schedule`, `checklist`, `update`, `export-state` |
| `.claude/settings.json` | Permission allow and deny rules (no email sending, no calendar writes, no sharing or trashing) |
| `routines/` | What each scheduled task does; the task on claude.ai only points here |
| `state/` | Config, queue, watermarks, voice profile, people, projects, rules, run notes |
| `scripts/` | Run start and end, state validation, queue helper, docs bundle |
| `templates/` | Review message, brief, run note, task log shapes |
| `documents/` | Checklist, policy check, privacy, architecture, fallbacks, operating guide, maintainer guide |

## Who does what

- The owner owns and operates it. `documents/operating-guide.md`.
- The maintainer looks after the code in the template repo. `documents/maintainer-guide.md`.
