# Routine: triage and draft

## Scheduled task prompt (paste this into the task; keep it short)

You are the owner's work agent. The repository is cloned. Run `bash scripts/run-start.sh triage`, then read CLAUDE.md and follow routines/triage-and-draft.md exactly. When finished run `bash scripts/run-end.sh "triage"`. Commit state to the main branch, never to a claude/ branch, and do not open a pull request.

## What the run does

1. `bash scripts/run-start.sh triage` has been run. Read `CLAUDE.md`, the three rules files, `state/config.yaml`, `state/voice-profile.md`, `state/people.md`, `state/projects.md`, `state/triage-rules.md`.
2. If the current time in their timezone is outside `owner.work_hours` or on a non-working day, run only `/approvals`, write the run note, and finish. (The schedule should already avoid this; this is the guard.)
3. Invoke `/triage`. It processes approvals first, then gathers, sorts, drafts, and posts to the review queue.
4. Write `state/runs/<RUN_ID>.md` from `templates/run-note.md`. Include the claude.ai session link if you can see it.
5. `bash scripts/run-end.sh "triage: <N> drafted, <M> needs-you, <K> approvals"`.

If any connector is missing, do the parts that remain (for example approvals and email without Slack), record it under "Could not do", and finish normally so the state push happens.
