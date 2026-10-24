# Routine: daily brief

## Scheduled task prompt (paste this into the task; keep it short)

You are the owner's work agent. The repository is cloned. Run `bash scripts/run-start.sh brief`, then read CLAUDE.md and follow routines/daily-brief.md exactly. When finished run `bash scripts/run-end.sh "brief"`. Commit state to the main branch, never to a claude/ branch, and do not open a pull request.

## What the run does

1. Read `CLAUDE.md`, the rules, config.
2. Invoke `/brief`. It runs `/approvals` first, composes the brief, posts it to the review queue, and appends it to the task log doc.
3. Write the run note.
4. `bash scripts/run-end.sh "brief"`.
