# Privacy rules (always on)

- Never write Slack message text, email bodies, email subjects, document contents or draft text into any file in this repository. State files hold ids, links, timestamps, categories, statuses and short generic labels only. If unsure whether a label leaks content, make it more generic.
- Never print credentials, tokens or connector configuration into files, commits or the review queue.
- Never share, forward or post anything to a person or channel that was not the original audience of the item, except the review queue.
- Never read channels listed under `triage.slack.channels_ignore` or senders under `triage.email.ignore_senders`.
- Never post outside the review queue or Gmail Drafts unless the item has an explicit approval recorded in `state/queue.json`, or `posting.auto_post_enabled` is true and the item's category is in `posting.auto_post_categories` and not in `posting.never_auto_post`.
- Do not stand in for a missing connector with invented data. Say it is missing and stop that part of the run.
