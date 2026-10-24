# Maintainer guide (for the maintainer)

You maintain code, prompts and docs. You never hold the owner's credentials, never see their `state/`, and never run the agent.

## Repos

- **Template** (yours): this repo. `state/` contains only the empty schemas committed here. It stays public so the owner can clone or import it. Do not rely on GitHub's "Use this template": the copy it makes has unrelated history, so `/update` and the upstream merge in `run-start.sh` cannot pull your changes into it.
- **The owner's instance**: a private repo under their GitHub account, cloned or imported from the template. You are not a collaborator. Their scheduled tasks run against it.

## Creating the owner's instance

The owner does this on their laptop (or with GitHub's importer for step 1 in the web-only fallback):

```
git clone https://github.com/vinmisra/work-agent.git work-agent && cd work-agent
git remote rename origin upstream
gh repo create work-agent --private --source=. --remote=origin --push
claude
/setup
```

`/setup` writes `runtime.upstream_remote` so `/update` and `scripts/run-start.sh` can pull your changes later.

## Shipping a change

1. Edit skills, routines, rules, scripts or docs in the template. Never put anything in `state/` beyond the schemas.
2. Run `bash scripts/validate-state.sh` and `claude plugin validate .`.
3. Test a skill locally: `claude --plugin-dir .` then `/work-agent:status` (works on empty state).
4. Commit and push. CI runs the validator.
5. Tell the owner to run `/update` (or wait: `run-start.sh` merges `upstream/main` at the start of every run when `runtime.upstream_remote` is set, so their runs pick up changes automatically; `/update` is for when they want it now or wants to see the diff).

## Changing behaviour safely

- Anything that posts or writes outside the review queue needs a rule in `.claude/rules/` and, if a tool is involved, a deny or allow rule in `.claude/settings.json`.
- Keep the scheduled task prompts in `routines/*.md` stable; the owner has pasted them into claude.ai. Put logic in the "What the run does" section and in skills.
- Add state fields through `scripts/queue.py` (`ALLOWED`) and `scripts/validate-state.sh` together.
- Do not log content. If you need an example to debug, ask the owner for a redacted description.

## Local test harness

`scripts/validate-state.sh` and `scripts/queue.py` run without connectors. For a dry run of a routine without connectors, start `claude` in the template clone and run `/triage --dry-run`; it will report the connectors as missing and exercise the state code paths.
