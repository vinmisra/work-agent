# Operating guide (for the owner)

## Day to day

- **Drafts** arrive in your Slack DM to yourself (or your private channel), one message each, with the context and a link to the original. Reply in that message's thread:
  - `approve` (or `send`, `yes`, `lgtm`) to post it as-is.
  - `edit: <your version>` to post your version. The agent learns from the difference.
  - `skip` to drop it.
  - Anything else is treated as a question; the agent answers in the thread and leaves the draft waiting.
- **Email drafts** are already in your Gmail Drafts. Send them from Gmail. The review message just tells you they exist.
- **"Needs you"** messages list the things the agent will not draft (people topics, commitments, executives, decisions). It is a list, not a draft.
- **Proactive results** are new docs under "Agent drafts" in your Drive. The agent never edits your existing documents.
- **The daily brief** lands at the end of the day: waiting on you, done, could not do, tomorrow.
- **The task log** is a Google Doc; its link is in every brief.

Approvals are picked up at the start of the next run (hourly during working hours). To act faster, open a session (below) and say "process approvals" or "send 14".

## Talking to it

- Open https://claude.ai/code, start a session on your agent repo, and say what you want: "what's waiting", "draft a reply to Priya about the Q1 plan", "always ignore #random", "stop drafting status updates for the leadership channel", "rebuild my voice profile".
- Every scheduled run is a session too: https://claude.ai/code/routines, pick the task, History, open the run. You can interrupt and redirect it there.
- On your laptop, `claude` inside the repo clone gives the same commands.

## Switching things on and off

- Pause everything: disable the tasks at https://claude.ai/code/routines.
- Stop drafting for a channel or person: tell it in a session, or edit `state/triage-rules.md`.
- Turn on auto-posting for a category (for example acknowledgements to your own team): first fill in `documents/ai-policy-check.md`, then set `posting.auto_post_enabled: true` and list the category under `posting.auto_post_categories` in `state/config.yaml`. The categories under `never_auto_post` cannot be enabled. Auto-posted messages are still copied to your queue.

## When something looks wrong

- Say "status" in a session. It reports missing connectors, failed pushes, and what to do.
- `/checklist` re-verifies the preconditions.
- If a run stopped at a permission prompt, open it from History and answer the prompt; then check row 11 of the checklist.
