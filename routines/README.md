# Scheduled tasks (Routines)

The schedule lives on the owner's claude.ai account (https://claude.ai/code/routines). Each task's prompt is the short paragraph under "Scheduled task prompt" in the matching file here; the rest of the file is what the run actually follows, so changing a file here changes the next run without touching claude.ai. `/schedule` prints the commands.

| Task | File | Cadence (their timezone) | Connectors |
|------|------|------------------------|------------|
| Triage and draft | `triage-and-draft.md` | Every hour at :07 during working hours, weekdays | Slack, Gmail, Google Drive, Google Calendar |
| Proactive tasks | `proactive.md` | Weekdays 07:17 | Slack, Google Drive |
| Daily brief | `daily-brief.md` | Weekdays 17:23 | Slack, Gmail, Google Drive, Google Calendar |

Cloud scheduled tasks cannot run more often than hourly. Approvals are processed at the start of every run, so a draft they approve is posted within an hour during working hours. For faster turnaround they can open any run's session from the task's History page, or run `/approvals` in a session of their own.

Every run: clones the repo fresh, runs `scripts/run-start.sh`, follows the file, writes a run note, runs `scripts/run-end.sh`, which pushes `state/` to `main`. Runs push to `main` because the prompt says so; without that line a cloud run pushes to a `claude/`-prefixed branch and the next run would not see the state.

Fallback prompt for an org that blocks GitHub: `fallback-google-docs-prompt.md`.
