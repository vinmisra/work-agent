# Work agent

A Claude Code agent that handles the reactive part of a manager's day under their own accounts: it triages Slack and email, drafts replies in their voice for their approval, takes a first crack at small tasks it finds in their notes, and sends a daily brief. It runs as scheduled cloud tasks on claude.ai against this repository, using the Slack, Gmail, Google Drive and Google Calendar connectors their org allows. Nothing runs on their laptop after setup and nothing runs on anyone else's machine.

Approve-to-send is the only mode until the owner decides otherwise. Email is never sent by the agent. State lives in `state/` as pointers and labels, never message content (see `documents/privacy-and-data-boundaries.md`).

## Install (the owner's laptop, once)

Before you start (about 30 minutes, most of it clicking "Connect"):

1. A claude.ai account on a plan that includes Claude Code (Pro, Max, Team or Enterprise). Use the work account if your employer provides one; on Team or Enterprise an org owner may need to enable Claude Code, scheduled tasks and the connectors (see `documents/claude-connector-checklist.md`).
2. Connect Slack, Gmail, Google Drive and Google Calendar at https://claude.ai/customize/connectors with your work Slack and Google accounts.
3. A GitHub account, connected to claude.ai at https://claude.ai/connect-github (the Claude GitHub App gets access to your agent repo after step 1 below).
4. On the laptop: `git`, the GitHub CLI (`brew install gh`, then `gh auth login`), and Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`, then `claude` and `/login` with the account from item 1).

Then:

```
# 1. Make a private copy of this repo under your GitHub account.
#    (Clone rather than "Use this template": a template copy has unrelated
#    history, so /update could not pull later fixes.)
git clone https://github.com/vinmisra/work-agent.git work-agent && cd work-agent
git remote rename origin upstream
gh repo create work-agent --private --source=. --remote=origin --push

# 2. Give the Claude GitHub App access to the new private repo:
#    https://github.com/apps/claude/installations/select_target

# 3. Optional: install the plugin so the commands work from any directory
claude plugin marketplace add ./
claude plugin install work-agent@work-agent

# 4. Set up (interactive, about 20 minutes)
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
