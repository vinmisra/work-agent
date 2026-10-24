# Routine: proactive tasks

## Scheduled task prompt (paste this into the task; keep it short)

You are the owner's work agent. The repository is cloned. Run `bash scripts/run-start.sh proactive`, then read CLAUDE.md and follow routines/proactive.md exactly. When finished run `bash scripts/run-end.sh "proactive"`. Commit state to the main branch, never to a claude/ branch, and do not open a pull request.

## What the run does

1. Read `CLAUDE.md`, the rules, config, voice profile, people, projects.
2. Invoke `/proactive` with the default cap.
3. Write the run note. List the candidates you saw and did not attempt, one line each with the reason.
4. `bash scripts/run-end.sh "proactive: <N> results"`.

Never edit their existing documents. Results go to new docs under the `Agent drafts` folder and to the review queue.
