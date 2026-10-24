# Fallback: web-only install (no CLI on the owner's laptop)

For an org that blocks installing the CLI. Everything works except the parts of `/voice` that read local Claude Code and Codex history.

1. Create the owner's private repo from the template (GitHub web: Use this template, or ask the maintainer to send the instructions in `maintainer-guide.md`).
2. Connect GitHub to claude.ai (https://claude.ai/connect-github) and give the Claude GitHub App access to the repo.
3. Connect Slack, Gmail, Google Drive and Google Calendar at https://claude.ai/customize/connectors.
4. Start a cloud session on the repo at https://claude.ai/code, mode Auto, and type `/setup`. The skills are in the repo, so `/setup` is available in the web session. It will skip local history and say so.
5. Create the scheduled tasks on the web at https://claude.ai/code/routines as `/schedule` prints them.
6. For the voice profile, the owner can later export their Claude.ai data and attach the export to a web session, then run `/voice --refresh`.
