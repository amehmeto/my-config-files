#!/usr/bin/env bash
# check-branch-sync.sh — PostToolUse hook.
#
# Detects, during active work, when the current branch has fallen behind
# origin/main and injects a directive into Claude's context to auto-sync.
# Read-only: it NEVER mutates git state (no merge/push from inside the hook —
# Claude does that at a clean point so conflicts and a dirty tree are handled).
#
# Throttled: fetches origin/main at most once per TTL window; otherwise it is an
# instant no-op so it adds no latency to the tool loop.
set -u

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git -C "$root" symbolic-ref --quiet --short HEAD 2>/dev/null) || exit 0
case "$branch" in
  main | demo) exit 0 ;;
esac

stamp=$(git -C "$root" rev-parse --git-path branch-sync-check 2>/dev/null) || exit 0
ttl=600
now=$(date +%s)
if [ -f "$stamp" ]; then
  last=$(cat "$stamp" 2>/dev/null || printf '0')
  [ $((now - last)) -lt "$ttl" ] && exit 0
fi
printf '%s' "$now" >"$stamp"

git -C "$root" fetch origin main --quiet 2>/dev/null || exit 0
behind=$(git -C "$root" rev-list --count "HEAD..origin/main" 2>/dev/null || printf '0')
[ "${behind:-0}" -gt 0 ] || exit 0

ctx="Branch '${branch}' is ${behind} commit(s) behind origin/main. Standing user instruction: auto-sync now WITHOUT asking. At a clean point (commit or stash any in-progress edits first), run: git merge origin/main --no-edit ; resolve any conflicts yourself ; then TZ=UTC SKIP_E2E_CHECK=true git push. Reconcile semantic breaks (compile/test) the merge introduces before pushing."

if command -v jq >/dev/null 2>&1; then
  jq -nc --arg c "$ctx" \
    '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$c}}'
else
  esc=$(printf '%s' "$ctx" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s"}}\n' "$esc"
fi
exit 0
