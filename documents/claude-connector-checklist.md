# Claude connector checklist (the owner's preconditions)

Everything the agent needs before the first scheduled run. The owner does the checks; the "Who" column says when an org admin is needed. `/checklist` verifies the rows marked "session" from inside a Claude Code session.

| # | Precondition | How to verify | Who | Verified by |
|---|--------------|---------------|-----|-------------|
| 1 | Their work Claude account is on a plan with Claude Code cloud sessions | Open https://claude.ai/code and start a session | owner | owner |
| 2 | Scheduled tasks (formerly Routines) are enabled for the org | https://claude.ai/code/routines shows "New task". Team and Enterprise owners toggle this under Organization settings, Capabilities, Remote sessions, "Scheduled tasks" | org owner if missing | owner |
| 3 | GitHub connected to claude.ai, with the Claude GitHub App installed on their agent repo | https://claude.ai/connect-github lists the repo; a cloud session can be started on it | owner | session |
| 4 | Slack connector enabled for the org and connected on their account | https://claude.ai/customize/connectors shows Slack as connected. Team and Enterprise: an owner enables it under Organization settings, Connectors, after the Claude in Slack app is installed in the workspace | org owner, then the owner | session |
| 5 | Gmail connector enabled and connected | Same page shows Gmail connected. Owner enables for the org first on Team and Enterprise | org owner, then the owner | session |
| 6 | Google Drive connector enabled and connected | Same page shows Google Drive connected | org owner, then the owner | session |
| 7 | Google Calendar connector enabled and connected (optional; the brief degrades without it) | Same page shows Google Calendar connected | org owner, then the owner | session |
| 8 | Slack workspace admin has approved the Claude app with the scopes the connector asks for (reading DMs and private channels, posting) | A test `slack_send_message` to themselves works and `slack_read_thread` reads a private channel they are in | Slack workspace admin | session (via /setup) |
| 9 | Google Workspace admin allows the Claude connectors for Gmail and Drive | Connecting the account at claude.ai does not fail with an admin-block message | Workspace admin | owner |
| 10 | A cloud environment with "Trusted" (default) or broader network access | Environment settings, Network access. Connector and GitHub traffic bypass the allowlist, so Trusted is enough | owner | owner |
| 11 | Auto permission mode available in cloud sessions | Start a cloud session; the mode dropdown offers "Auto". If the org disabled it (`permissions.disableAutoMode`), scheduled runs will stop at tool prompts | org admin if missing | owner |
| 12 | Their agent repo is private, under their GitHub account, and `main` accepts pushes from the cloud session | `git push --dry-run` from a cloud session on the repo | owner | session |
| 13 | AI policy reviewed for connector use and approve-to-send drafting | `documents/ai-policy-check.md` Decision section filled | owner (with their manager or IT contact) | owner |
| 14 | Org does not IP-allowlist Claude (Anthropic-hosted cloud sessions fail with an authentication error if it does) | A cloud session starts at all | org admin if failing | owner |

Notes
- Nothing here requires company IT to run or host anything. Rows 2, 4 to 9, 11 and 14 are toggles or app approvals.
- The CLI on their laptop is used once, for `/setup` and `/schedule`. It needs them to be logged in to Claude Code with the work claude.ai account (`claude` then `/login`).
- If row 3 or 12 cannot pass because the org blocks GitHub for Claude, use `documents/fallback-google-docs.md`.
- If they cannot run the CLI at all, use `documents/fallback-web-only-install.md`.
