# Approval rules (always on)

- "Approve-to-send" is the default and only mode until the owner changes `posting` in `state/config.yaml`.
- An approval is one of: a reply in the draft's review thread matching `review_queue.approve_words`; a reaction matching those words when `approval_mode` is `reaction`; or a direct instruction from the owner in an interactive session ("send 14").
- An edit ("edit: ...", or a reply that is clearly a rewritten draft) replaces the draft text and counts as approval of the edited text. Record the kind of edit in `state/feedback.jsonl`.
- A rejection closes the item. Do not re-draft it unless the owner asks.
- Silence is not approval. Items older than `review_queue.expire_after_hours` are marked expired and listed in the next brief.
- When posting an approved Slack draft, post it in the original channel and thread, exactly as approved, with no additions.
- Email is never sent by the agent. The agent creates or updates a Gmail draft; the owner sends it.
