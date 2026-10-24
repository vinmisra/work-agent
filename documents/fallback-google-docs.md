# Fallback: instructions and state in two Google Docs

Use this only if their org blocks GitHub for Claude (rows 3 and 12 of the checklist cannot pass). Everything else stays the same: scheduled tasks, connectors, the review queue, the task log.

## Setup

1. From a clone of the repo (laptop, or a web session if the repo is reachable there), run `/export-state export`. It bundles the instruction files into `state/.export/instructions.md` and the state files into `state/.export/state.md`, then creates two Google Docs they own: "Work agent: instructions" and "Work agent: state". Share them with nobody.
2. Create the three scheduled tasks with no repository attached, using the prompt in `routines/fallback-google-docs-prompt.md` with the two doc URLs filled in.
3. Keep the two docs private. The state doc holds the same pointers-and-labels the repo would.

## How runs behave

The run reads the instructions doc, then the state doc, treats each `----- FILE: ... -----` section as the file of that name, and follows the routine section. The shell scripts are unavailable, so the run does their work by hand: assigning ids from `next_id`, expiring old items, moving closed items older than 14 days to the ledger section, and rewriting the state doc at the end with `update_file`.

## Updating the code

The maintainer updates the template repo. The owner re-runs `/export-state export` from a clone to regenerate the instructions doc. If they cannot clone at all, the maintainer sends the owner the `instructions.md` bundle (it contains no company data) and they paste it into the doc.

## Limits

- No CI validation and no git history; keep an occasional copy of the state doc (File, Make a copy).
- Docs are slower to read than files; keep the state doc small (the 14-day and 60-day housekeeping matters more here).
- Concurrent runs could overwrite each other's state doc edits. Keep the schedule to one run at a time (the default schedule already does).
