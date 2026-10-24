# State handling rules (always on)

- At the start of every routine run: `scripts/run-start.sh` (pulls latest state, validates it, prints the run id). At the end: `scripts/run-end.sh "<summary>"` (validates, commits, pushes with retry). Never skip the end step; a run that did work but did not push its state will redo the work next time.
- Edit state files with small, targeted changes. Prefer appending to `.jsonl` files over rewriting `.json` files.
- Every item gets a sequential id from `queue.json.next_id`. Ids are never reused.
- Every run writes `state/runs/<run-id>.md` using `templates/run-note.md`.
- If `scripts/run-end.sh` fails to push after its retries, say so in the run output and in the next brief; do not retry forever.
