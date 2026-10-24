# Shared helpers for run-start.sh and run-end.sh. Sourced, not executed.
log() { printf '%s\n' "$*" >&2; }
cfg() { sed -n "s/^  $1: *\"\{0,1\}\([^\"#]*\)\"\{0,1\}.*/\1/p" state/config.yaml | head -1 | xargs 2>/dev/null || true; }
BRANCH="$(cfg state_branch)"; BRANCH="${BRANCH:-main}"
FALLBACK="$(cfg fallback_state_branch)"; FALLBACK="${FALLBACK:-agent-state}"
UPSTREAM="$(cfg upstream_remote)"
retry() { local i; for i in 1 2 3 4; do "$@" && return 0; sleep $((2 ** i)); done; return 1; }
configure_git() {
  git config merge.statejson.name "semantic merge for agent state json"
  git config merge.statejson.driver "python3 -I scripts/merge-state.py %O %A %B"
  git config merge.union.driver true >/dev/null 2>&1 || true   # built-in; the line is a no-op guard
  git config user.name  >/dev/null 2>&1 || git config user.name  "${GIT_AUTHOR_NAME:-work-agent}"
  git config user.email >/dev/null 2>&1 || git config user.email "${GIT_AUTHOR_EMAIL:-work-agent@users.noreply.github.com}"
  git config push.negotiate false >/dev/null 2>&1 || true
}
# Resolve leftover conflicts after a merge/rebase step: json via the driver already ran;
# for anything else keep the side given ($1 = ours|theirs).
resolve_leftovers() {
  local side="$1" f
  for f in $(git diff --name-only --diff-filter=U); do
    case "$f" in
      state/queue.json|state/seen.json)
        git show ":1:$f" > "/tmp/.base.$$" 2>/dev/null || : > "/tmp/.base.$$"
        git show ":2:$f" > "/tmp/.ours.$$"; git show ":3:$f" > "/tmp/.theirs.$$"
        if python3 -I scripts/merge-state.py "/tmp/.base.$$" "/tmp/.ours.$$" "/tmp/.theirs.$$"; then cp "/tmp/.ours.$$" "$f"; else git checkout "--$side" -- "$f"; fi
        rm -f "/tmp/.base.$$" "/tmp/.ours.$$" "/tmp/.theirs.$$" ;;
      *) git checkout "--$side" -- "$f" ;;
    esac
    git add -- "$f"
  done
}
# Merge a ref into HEAD using the state drivers; never leaves markers. Returns 1 if it had to abort.
merge_with_state_driver() {
  local ref="$1"
  git merge-base --is-ancestor "$ref" HEAD && return 0
  if git merge -q --no-edit "$ref" >/dev/null 2>&1; then return 0; fi
  resolve_leftovers theirs
  if git diff --name-only --diff-filter=U | grep -q .; then git merge --abort 2>/dev/null || true; return 1; fi
  GIT_EDITOR=true git commit -q --no-edit >/dev/null 2>&1 || true
  if ! bash scripts/validate-state.sh >/dev/null 2>&1; then git reset -q --hard ORIG_HEAD; return 1; fi
  return 0
}
