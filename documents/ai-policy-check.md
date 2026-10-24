# AI policy check

The owner fills this in before enabling anything beyond approve-to-send. The agent reads the "Decision" section at the start of every run and refuses to auto-post if it is not marked "Allowed".

The maintainer does not fill this in and does not need to see it.

## Questions to answer from the policy and from their manager or IT contact

1. Does the policy allow using Claude (the company's approved deployment) to read Slack, Gmail and Drive on their behalf? Which connectors has the org approved?
2. Does the policy allow an AI assistant to send Slack messages or email as them without a disclosure marker? If a marker is required, set `posting.disclosure_suffix` in `config.yaml` (for example "(drafted with AI)").
3. Are there channels, document classes or topics that must never be read by an AI tool? List them under `triage.slack.channels_ignore` and in `state/triage-rules.md`.
4. Is storing pointers (links, ids) and style descriptors in a private GitHub repo under their account acceptable? If not, use `documents/fallback-google-docs.md`.
5. Who did the owner confirm this with, and when?

## Decision

- Reading Slack, Gmail, Drive through connectors: NOT YET CHECKED
- Drafting for their approval (default mode): NOT YET CHECKED
- Auto-posting in low-risk categories: NOT YET CHECKED
- Disclosure marker required: UNKNOWN
- Checked with: 
- Date: 

Change each line to "Allowed", "Not allowed" or "Allowed with marker". The agent treats anything other than "Allowed" or "Allowed with marker" as "Not allowed".
