---
name: schedule
description: Print the exact commands and settings to create the three scheduled tasks (triage and draft, proactive, daily brief) on claude.ai/code, using the prompts in routines/. Use after /setup or when the schedule needs changing.
disable-model-invocation: true
argument-hint: "[triage|proactive|brief|all]"
---

# /schedule

Scheduled tasks (the feature formerly called Routines) live on the owner's claude.ai account, not in this repo. Each task's prompt is short and only tells the run which file in `routines/` to follow, so the repo stays the source of truth.

Read `state/config.yaml` for their timezone and working hours, and read `routines/README.md` for the schedule table. Then print, for each task requested (default all):

1. The `/schedule` command for the terminal CLI. The CLI command takes natural language, so print it exactly as:

   `/schedule <cadence in their timezone>: <the one-paragraph prompt from the routine file's "Scheduled task prompt" section>`

   Example cadences: "every weekday at 8:07, 9:07, ... 17:07 America/Los_Angeles" (hourly during work hours; the minimum interval for cloud tasks is one hour, so never ask for less), "every weekday at 07:17", "every weekday at 17:23". Off-hour minutes avoid the on-the-hour queue delay.

2. The equivalent web steps: https://claude.ai/code/routines, New task, Set up manually, paste the same prompt, choose the model, set the schedule, and under Advanced settings pick this repository, the cloud environment, and in the Connectors tab keep only Slack, Gmail, Google Drive and Google Calendar.

3. The settings that matter for every task:
   - Repository: their agent repo. Runs start from the default branch; state is pushed back to `main` by `scripts/run-end.sh`. If `main` is protected, set `runtime.state_branch` in config to a branch the run can push to.
   - Connectors: Slack, Gmail, Google Drive, Google Calendar. Remove everything else.
   - Environment: one whose network access is at least "Trusted" (default). Connector and GitHub traffic bypass the allowlist, so nothing custom is needed.
   - Model: their choice; the routine files do not pin one.
   - Permission mode: runs start in Auto mode. If their org has disabled Auto mode, runs will pause on tool prompts and they must answer them from the task's History page. Say this plainly.

4. After creation: `/schedule list` to confirm, `/schedule run <name>` for a first manual run, and a reminder that every run shows up as a session in the task's History where they can open it and redirect it.

Do not try to run `/schedule` yourself; it is a built-in command they type. If they are in a cloud session, say that `/schedule` only works in the terminal CLI and give the web steps.
