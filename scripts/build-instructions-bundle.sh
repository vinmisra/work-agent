#!/usr/bin/env bash
# Bundles the instruction files into one markdown file and the state files into another,
# for the Google Docs fallback (documents/fallback-google-docs.md).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
mkdir -p state/.export
{
  echo "# Work agent: instructions"
  echo
  echo "Bundle built $(date -u +%Y-%m-%dT%H:%M:%SZ) from the repo. Each section is one file. Edit here only when the repo is unreachable."
  for f in CLAUDE.md .claude/rules/*.md .claude/skills/*/SKILL.md routines/*.md templates/*.md; do
    echo; echo "----- FILE: $f -----"; echo; cat "$f"
  done
} > state/.export/instructions.md
{
  echo "# Work agent: state"
  echo
  echo "Bundle built $(date -u +%Y-%m-%dT%H:%M:%SZ). Each section is one file. The run reads this at start and rewrites it at the end."
  for f in state/config.yaml state/queue.json state/seen.json state/voice-profile.md state/people.md state/projects.md state/triage-rules.md state/feedback.jsonl state/ledger.jsonl; do
    echo; echo "----- FILE: $f -----"; echo; cat "$f"
  done
} > state/.export/state.md
wc -c state/.export/instructions.md state/.export/state.md
