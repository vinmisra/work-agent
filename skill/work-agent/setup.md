# Setup

The owner just said "set up my work agent". This is a conversation, about 15 minutes. Ask one thing at a time, show what you found, and get a yes before saving anything they will live with. Keep a list of anything you could not verify for the summary at the end.

## 1. Check the connectors

Look for these tools (use tool search if your tools are loaded on demand):
- Slack: send message, read channel, read thread, search public and private, search users, read user profile.
- Gmail: search threads, read thread, create draft.
- Google Drive: search files, read file content, create file, update file.
- Google Calendar: list events (optional).

If Slack, Gmail or Drive is missing, stop and tell them exactly which, with: "Connect it under Settings > Connectors on claude.ai, then start a new chat and say 'set up my work agent' again. If it is not listed, your Claude admin needs to enable it for the org." Calendar missing is fine; the brief just leaves out tomorrow.

## 2. Who they are

Ask what name they go by. Find them in Slack with search users and confirm with read user profile; record user id and handle. Find their email from a Gmail search for `from:me` (the sender address). Ask their timezone and work hours (suggest the profile's timezone and 9 to 6 weekdays).

## 3. The review DM

Send a Slack message to their own user id: "🤖 Work agent is set up. Drafts will show up here. Reply in a draft's thread with approve, edit: <your version>, or skip." Record the channel id it returns (if none, search for that exact text and take the channel). Ask them to check it arrived.

Then check mention search: ask for one recent message that mentioned them, search for `<@USERID> after:<yesterday>` and `@handle after:<yesterday>`, and record whichever finds it (default handle).

## 4. Their notes

Ask which Google Docs or folders hold their running notes, 1:1 notes and to-do lists. Record the links. These are what the daily note tasks read. "None" is fine.

## 5. What to stay out of

Ask for Slack channels the agent should never read (social, confidential, HR) and email senders to ignore. Add common automated senders (noreply@, no-reply@, calendar-notification@, notifications@) unless they object.

## 6. Style guide and references

Learn how they write, across everything they write: Slack, email, memos and docs, presentations, and anything else you find. Read as widely and deeply in their own work as you need to; it is their writing that matters, not other people's.

Write what you learn into the Style section of the memory doc: a description of each medium and audience they write for, in whatever form best captures it, with excerpts and examples where they make the point better than a description would. Build a References index alongside it: links to the pieces that best show how they write, each with a quick description, so a later run can go and read them.

Show them both and ask what's off and what you missed. Then write a couple of sample replies to recent messages (do not post them) and ask whether they sound like them, and refine until they do.

## 7. People and projects

From their recent Slack messages, list the people they deal with most. Look up names and titles. Ask them to confirm and to add their manager, direct reports and key partners, with a drafting note for each if they have one ("keep it short with her", "always cc on launches"). From the channels they post in most and the Drive docs they edited in the last 60 days, list their projects with one-line status and links; ask them to correct it.

## 8. Save the memory doc

Create a Google Doc titled exactly `Work agent memory` with Drive create file, in the shape of `memory-doc.md`, with everything from steps 2 to 7. Read it back to confirm it saved. Tell them it is in their Drive, private to them, and that they can edit it any time.

## 9. Try it

Ask if they want a first check-in now with at most 3 drafts so they see what lands in their DM. If yes, follow `check-in.md`, skipping note tasks and the brief.

## 10. Schedule it

One scheduled task does everything: approvals and triage every hour, note tasks on the first run of the day, the brief at the end of the day.

If you can create scheduled tasks from this chat, offer to create it now: name "Work agent", weekdays, every hour from the start to the end of their work hours in their timezone, at a few minutes past the hour (for example :07), with the prompt below. Otherwise give them these steps:

1. In claude.ai, open Scheduled tasks (in the sidebar, or Settings) and choose New task.
2. Name: Work agent. Schedule: hourly on weekdays during work hours; if hourly is not offered, pick the most frequent option (three times a day is fine).
3. Prompt, pasted exactly:

   `Work agent check-in. Use the work-agent skill and follow its check-in mode.`

4. Make sure Slack, Gmail, Google Drive and Google Calendar are on for the task, and the work-agent skill is available.

Then finish with a short summary: what is set up, where drafts will appear, how to approve, where the memory doc is, and anything you could not verify.
