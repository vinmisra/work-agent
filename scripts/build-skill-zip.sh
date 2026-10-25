#!/usr/bin/env bash
# Package skill/work-agent as the zip the owner uploads to claude.ai.
# Usage: bash scripts/build-skill-zip.sh [out.zip]   (default: dist/work-agent-skill.zip)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="${1:-$ROOT/dist/work-agent-skill.zip}"
case "$out" in /*) ;; *) out="$PWD/$out" ;; esac
mkdir -p "$(dirname "$out")"
rm -f "$out"
cd "$ROOT/skill"
head -1 work-agent/SKILL.md | grep -q '^---$' || { echo "SKILL.md is missing frontmatter" >&2; exit 1; }
zip -qr -X "$out" work-agent
echo "$out"
