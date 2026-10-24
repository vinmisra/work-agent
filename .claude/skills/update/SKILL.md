---
name: update
description: Pull code updates from the template repo (the maintainer's) into the owner's instance without touching state/. Use when they want the latest skills and routines, or when runtime.upstream_remote is set and they ask to update.
disable-model-invocation: true
---

# /update

1. Read `runtime.upstream_remote` from `state/config.yaml`. If empty, ask for the template repo URL and write it there.
2. `git remote add upstream <url>` if missing, `git fetch upstream main`.
3. Show `git log --oneline HEAD..upstream/main -- . ':!state'` so they see what changed.
4. `git merge --no-edit upstream/main`. If git refuses with "unrelated histories" (the repo was made with GitHub's "Use this template"), run it once with `--allow-unrelated-histories`, resolve every conflict outside `state/` in favour of upstream (`git checkout --theirs -- <file>`), and later runs merge normally. If the merge touches `state/`, keep ours: `git checkout --ours -- state/ && git add state/` and finish the merge.
5. `bash scripts/validate-state.sh`, `git push -u origin main`.
6. Tell them nothing else is needed: scheduled runs clone fresh and will use the new code on their next run.
