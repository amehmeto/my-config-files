#!/bin/bash
# Claude Code status line: branch + PR badge.
# Claude Code's native PR badge is lazy ("absent until a PR is found"), so when
# the stdin JSON lacks .pr we resolve it ourselves via gh, cached per branch.

input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
pr_number=$(printf '%s' "$input" | jq -r '.pr.number // empty')
pr_url=$(printf '%s' "$input" | jq -r '.pr.url // empty')

branch=""
[ -n "$cwd" ] && branch=$(cd "$cwd" 2>/dev/null && git branch --show-current 2>/dev/null)

if [ -z "$pr_number" ] && [ -n "$branch" ]; then
  cache_dir="${TMPDIR:-/tmp}/claude-statusline-pr"
  mkdir -p "$cache_dir"
  repo_root=$(cd "$cwd" && git rev-parse --show-toplevel 2>/dev/null)
  key=$(printf '%s' "$repo_root:$branch" | shasum | cut -c1-16)
  cache="$cache_dir/$key"

  cached=""
  age=999999
  if [ -f "$cache" ]; then
    cached=$(cat "$cache")
    age=$(( $(date +%s) - $(stat -f %m "$cache") ))
  fi

  # Re-check "no PR" often (a PR may have just been opened); trust a hit longer.
  ttl=600
  [ "$cached" = "none" ] && ttl=60

  if [ "$age" -ge "$ttl" ]; then
    (
      cd "$cwd" || exit
      result=$(gh pr view --json number,url -q '"\(.number)\t\(.url)"' 2>/dev/null) || result="none"
      [ -z "$result" ] && result="none"
      printf '%s\n' "$result" >"$cache.tmp" && mv "$cache.tmp" "$cache"
    ) >/dev/null 2>&1 &
  fi

  if [ -n "$cached" ] && [ "$cached" != "none" ]; then
    pr_number=${cached%%$'\t'*}
    pr_url=${cached#*$'\t'}
  fi
fi

CYAN=$'\033[36m'
GREEN=$'\033[32m'
RESET=$'\033[0m'

out=""
[ -n "$branch" ] && out="${CYAN}⎇ ${branch}${RESET}"

if [ -n "$pr_number" ]; then
  label="PR #${pr_number}"
  if [ -n "$pr_url" ]; then
    label=$'\033]8;;'"${pr_url}"$'\033\\'"${label}"$'\033]8;;\033\\'
  fi
  [ -n "$out" ] && out="$out · "
  out="${out}${GREEN}${label}${RESET}"
fi

[ -n "$out" ] && printf '%s\n' "$out"
