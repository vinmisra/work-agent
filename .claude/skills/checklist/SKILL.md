---
name: checklist
description: Walk through documents/claude-connector-checklist.md interactively and verify each precondition that can be verified from inside this session (connectors present, repo reachable, scheduled tasks available). Use before /setup, or when a scheduled run fails for environment reasons.
disable-model-invocation: true
---

# /checklist

Read `documents/claude-connector-checklist.md`. For each item, do the verification it describes if it can be done from here (tool presence via ToolSearch, `git push --dry-run`, reading `state/config.yaml`), otherwise ask the owner for the answer. Print a table: item, status (verified / they confirmed / missing / unknown), what to do about it, who does it (them, their org admin). Do not change any files. End with the shortest list of actions that would make every item pass.
