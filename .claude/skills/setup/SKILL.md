---
name: setup
description: One-time setup of the owner's work agent. Verifies connectors, identifies their Slack and email identity, creates the review queue and the task log doc, builds their voice profile, seeds people and projects, writes config, pushes state, and prints the schedule commands. Run once from their laptop CLI inside a clone of their agent repo.
disable-model-invocation: true
argument-hint: "[--quick]  (skip the voice rebuild if a profile exists)"
---

# /setup

You are setting the agent up for its owner. Work interactively: ask one question at a time, show what you found, and get a yes before writing anything they will live with (config, voice profile, people, projects). Keep a running list of anything you could not verify; it goes in the final summary.

Preconditions to check before anything else:

1. **Environment.** Confirm this is the terminal CLI on their machine (not a cloud session) by checking for `~/.claude` and a writable home. If this is a cloud session, continue but skip the local-history parts of `/voice` and say so.
2. **Repository.** Run `git rev-parse --show-toplevel` and `git remote -v`. You must be inside a clone of *the owner's* agent repo (private, under their GitHub account). If this is the maintainer's template clone (the remote is theirs), stop and walk them through `documents/maintainer-guide.md` section "Creating the owner's instance". If there is no `origin`, ask for their repo URL and add it. Verify push access with `git push --dry-run -u origin main`.
3. **Connectors.** Use ToolSearch with `+Slack`, `+Gmail`, `+Google_Drive`, `+Google_Calendar` and record which of these exist: `slack_send_message`, `slack_read_thread`, `slack_search_public_and_private`, `slack_read_channel`, `slack_search_users`, `slack_read_user_profile`, `create_draft` (Gmail), `search_threads` (Gmail), `list_drafts` (Gmail), `create_file`, `update_file`, `read_file_content`, `search_files` (Drive), `list_events` (Calendar). Slack, Gmail and Drive are required. Calendar is optional (brief degrades without it). For anything missing, point them to https://claude.ai/customize/connectors and to `documents/claude-connector-checklist.md`, then stop; they restart `claude` after connecting (connectors load at session start).

Then, in order:

4. **Identity.** Ask for their name as they want to be addressed. Find their Slack user with `slack_search_users` (their name) and confirm with `slack_read_user_profile`. Find their email address from a Gmail `search_threads` for `from:me` (take the sender address). Ask for their timezone and working hours. Write `owner` in `state/config.yaml`.
5. **Review queue.** Ask: a DM to themselves (default) or a private channel. For the DM, send a message with `slack_send_message` to their own user id: "Work agent set up. Drafts will land here. Reply in a draft's thread with approve, edit: <text>, or skip." Record the channel id the tool returns (if it returns none, search with `slack_search_public_and_private` for that exact text and take the channel from the result). For a private channel they created, find it with `slack_search_channels`, send the same message, record the id and name. Write `review_queue`.
6. **Mention query probe.** Ask them for one recent message that mentioned them. Run `slack_search_public_and_private` with `<@OWNER_ID> after:<yesterday>` and then with `@<handle> after:<yesterday>`. Record which form found it in `triage.slack.mention_query` as `userid` or `handle`. If neither works, record `handle` and note it in the summary.
7. **Task log.** Create a Google Doc titled "Agent task log" from `templates/task-log-doc.md` with Drive `create_file`. Record `task_log.doc_id` and `doc_url`. Append a line "Created by /setup on <date>" and read it back to prove `update_file` works.
8. **Voice profile.** Unless `--quick` was given and `state/voice-profile.md` is already built, run `/voice`.
9. **People.** From their last 200 Slack messages (`slack_search_public_and_private`, `from:<@OWNER_ID>`), list the people and channels they interact with most. For each person: `slack_read_user_profile` for name and title. Ask them to confirm roles and relationships for the top 15 and to add their manager, direct reports, and key partners. Write `state/people.md`. Names, ids, roles, relationship, one drafting note each. No message content.
10. **Projects.** From the channels they post in most, the Drive files they modified in the last 60 days (`search_files` with `owner = 'me' and modifiedTime > ...`), and their description, write `state/projects.md`: name, one-line status, links, who is on it, what they want from it. Ask them to correct it.
11. **Notes.** Ask which Google Docs or folders hold their running notes, 1:1 notes and to-do lists. Record their ids in `triage.drive.notes_docs` and `notes_folders`. These are what `/proactive` reads.
12. **Ignore lists.** Ask for channels that should never be read (social, confidential, HR) and senders to ignore. Write them to config. Add the standard bot senders if they have none.
13. **Policy.** Open `documents/ai-policy-check.md` and ask them to fill in the Decision section now or later. Leave `posting.auto_post_enabled: false` regardless.
14. **Validate and push.** `bash scripts/validate-state.sh`, then `bash scripts/run-end.sh "setup"`. Confirm the push landed (`git log origin/main -1`).
15. **GitHub connection for cloud runs.** Remind them that the claude.ai GitHub connection must have access to this repo (https://claude.ai/connect-github, Claude GitHub App installed on the repo). Scheduled tasks turn off if the GitHub connection is missing for 72 hours.
16. **Dry run.** Offer to run `/triage` now with a cap of 3 drafts so they see what lands in the queue. Then offer `/brief`.
17. **Schedule.** Run `/schedule` to print the three scheduled-task commands and the web alternative.

Finish with a summary: what is configured, what they should check in Slack and in the task log doc, what could not be verified, and the three schedule commands again.
