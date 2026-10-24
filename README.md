# Work agent

A Claude agent that handles the reactive part of a manager's day under their own accounts: it triages Slack and email, drafts replies in their voice for their approval, takes a first crack at small tasks it finds in their notes, and sends a daily brief. It runs as a scheduled task on claude.ai, using the Slack, Gmail, Google Drive and Google Calendar connectors their org allows. Nothing runs on their laptop or on anyone else's machine.

Approve-to-send is the only mode until the owner decides otherwise. Email is never sent by the agent. Its memory holds settings, descriptors and pointers, never message content (see `documents/privacy-and-data-boundaries.md`).

## Install (no GitHub, no terminal)

The agent is one claude.ai skill plus one scheduled task. Its memory is a private Google Doc in the owner's Drive; drafts wait for approval in their Slack DM to themselves.

1. **Connect** Slack, Gmail, Google Drive and Google Calendar in claude.ai, Settings, Connectors, with your work accounts.
2. **Upload the skill**: claude.ai, Settings, Capabilities, Skills, upload `work-agent-skill.zip` (build it with `bash scripts/build-skill-zip.sh`, or get it from the maintainer).
3. **Set up**: in a new chat, say `set up my work agent` and answer its questions (about 15 minutes).
4. **Schedule**: the setup chat creates the scheduled task, or gives you one prompt to paste into a new scheduled task.

If an item is missing on a Team or Enterprise plan (connectors, skills, scheduled tasks), an org owner has to switch it on. Updating means uploading a newer zip; the memory doc carries over.

The skill source is in `skill/work-agent/`: `SKILL.md` (rules and modes), `setup.md`, `check-in.md`, `memory-doc.md`, `messages.md`.

## Advanced: run from a git repo

Everything below describes the original design, where the agent runs as Claude Code cloud tasks against a private copy of this repo and keeps state in `state/`. It adds version history and CI checks on state at the cost of a GitHub account and a terminal install.

```
git clone https://github.com/vinmisra/work-agent.git work-agent && cd work-agent
git remote rename origin upstream
gh repo create work-agent --private --source=. --remote=origin --push
claude
/setup
/schedule
```

Preconditions are in `documents/claude-connector-checklist.md`.

## Layout

| Path | Purpose |
|------|---------|
| `skill/work-agent/` | The claude.ai skill (default install) |
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
