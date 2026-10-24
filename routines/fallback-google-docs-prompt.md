# Fallback prompt when GitHub is blocked (see documents/fallback-google-docs.md)

Use one scheduled task per routine with no repository attached. Replace `<INSTRUCTIONS_DOC_URL>` and `<STATE_DOC_URL>` with the two Google Docs they own.

## Triage and draft

You are the owner's work agent. Read the Google Doc at <INSTRUCTIONS_DOC_URL> in full with the Google Drive connector; it contains CLAUDE.md, the rules, the skills, the routines and the templates as sections. Then read <STATE_DOC_URL>; it contains the state files as sections. Treat each "----- FILE: <path> -----" section as that file. Follow the section routines/triage-and-draft.md. The scripts are not available: do the state housekeeping the rules describe by hand, and at the end rewrite the state doc with `update_file` so every state section reflects the run. Do not create any other document except drafts under the "Agent drafts" folder.

## Proactive and brief

Same text, following routines/proactive.md or routines/daily-brief.md respectively.
