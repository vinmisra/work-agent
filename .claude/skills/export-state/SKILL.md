---
name: export-state
description: Fallback for an org that blocks GitHub. Exports the instructions (CLAUDE.md, rules, skills, routines, templates) into one Google Doc and the state directory into a second Google Doc they own, or imports them back. Use only when documents/fallback-google-docs.md applies.
disable-model-invocation: true
argument-hint: "export | import"
---

# /export-state

Follow `documents/fallback-google-docs.md`. With `export`: run `bash scripts/build-instructions-bundle.sh` to produce `state/.export/instructions.md` and `state/.export/state.md`, then create or update two Google Docs titled "Work agent: instructions" and "Work agent: state" with Drive `create_file` / `update_file`, and print both URLs plus the scheduled-task prompt from `routines/fallback-google-docs-prompt.md`. With `import`: read the two docs and write their sections back to the matching files, then `bash scripts/validate-state.sh`.
