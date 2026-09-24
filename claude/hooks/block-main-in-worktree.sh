#!/usr/bin/env bash
# PreToolUse/Bash guard: keep agents off the `main` branch.
#
# A git branch can only be checked out in one working tree at a time. When an
# agent's worktree takes `main`, every other checkout of the repo is locked out
# of it ("fatal: 'main' is already used by worktree at ..."). This hook denies
# the two commands that take it:
#
#   * `git checkout main` / `git switch main` -- only inside a linked worktree
#   * `git worktree add <path> main`          -- anywhere
#
# Only Claude's Bash tool goes through hooks, so the user's own terminal is
# unaffected.
#
# Written for bash 3.2 (the macOS system bash).

set -u

input=$(cat)

command_text=$(printf '%s' "$input" | /usr/bin/jq -r '.tool_input.command // empty' 2>/dev/null)
case "$command_text" in
  *git*) ;;
  *) exit 0 ;;
esac

deny() {
  /usr/bin/jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# Walk past launchers (rtk, command, sudo, nice) to the git token, then past
# git's own options, and return the subcommand plus the index after it.
# Sets: SUB, IDX. Returns 1 when the segment is not a git invocation.
parse_git_segment() {
  local i=0 n=${#TOK[@]}
  while [ "$i" -lt "$n" ]; do
    case "${TOK[$i]##*/}" in
      git) break ;;
      rtk|command|sudo|nice|env) ;;
      *) return 1 ;;
    esac
    i=$((i + 1))
  done
  [ "$i" -lt "$n" ] || return 1
  i=$((i + 1))

  SUB=""
  while [ "$i" -lt "$n" ]; do
    case "${TOK[$i]}" in
      -C|-c|--git-dir|--work-tree|--namespace|--exec-path) i=$((i + 2)) ;;
      -*) i=$((i + 1)) ;;
      *) SUB="${TOK[$i]}"; i=$((i + 1)); break ;;
    esac
  done
  [ -n "$SUB" ] || return 1
  IDX=$i
  return 0
}

# True when the segment switches the working tree onto `main`.
# `git checkout main -- file` and `git checkout main file` restore files rather
# than switch, so `main` must be the segment's only positional argument.
switches_to_main() {
  case "$SUB" in checkout|switch) ;; *) return 1 ;; esac

  local i=$IDX n=${#TOK[@]}
  local count=0 first="" seen_dashdash=0
  while [ "$i" -lt "$n" ]; do
    case "${TOK[$i]}" in
      --) seen_dashdash=1; break ;;
      -b|-B|--orphan)
        i=$((i + 1))
        [ "$i" -lt "$n" ] || break
        count=$((count + 1))
        [ "$count" -eq 1 ] && first="${TOK[$i]}"
        ;;
      -*) ;;
      *)
        count=$((count + 1))
        [ "$count" -eq 1 ] && first="${TOK[$i]}"
        ;;
    esac
    i=$((i + 1))
  done

  [ "$seen_dashdash" -eq 0 ] || return 1
  [ "$count" -eq 1 ] || return 1
  [ "$first" = "main" ]
}

# True when the segment is a `git worktree add` that puts `main` in the new tree.
# `-b <new> main` only branches from main, so the name after -b is what counts.
# With no -b, the branch taken is the second positional, or -- when that is
# absent -- the one git guesses from the path's basename.
adds_worktree_on_main() {
  [ "$SUB" = "worktree" ] || return 1

  local i=$IDX n=${#TOK[@]}
  [ "$i" -lt "$n" ] && [ "${TOK[$i]}" = "add" ] || return 1
  i=$((i + 1))

  local has_new=0 new_branch="" detach=0 count=0 path="" second=""
  while [ "$i" -lt "$n" ]; do
    case "${TOK[$i]}" in
      -b|-B|--orphan)
        i=$((i + 1))
        [ "$i" -lt "$n" ] || break
        has_new=1
        new_branch="${TOK[$i]}"
        ;;
      --detach|-d) detach=1 ;;
      --reason) i=$((i + 1)) ;;
      -*) ;;
      *)
        count=$((count + 1))
        [ "$count" -eq 1 ] && path="${TOK[$i]}"
        [ "$count" -eq 2 ] && second="${TOK[$i]}"
        ;;
    esac
    i=$((i + 1))
  done

  if [ "$has_new" -eq 1 ]; then
    [ "$new_branch" = "main" ]
    return
  fi
  [ "$detach" -eq 0 ] || return 1

  local taken="$second"
  [ -n "$taken" ] || taken="${path##*/}"
  case "$taken" in
    main|refs/heads/main) return 0 ;;
  esac
  return 1
}

in_linked_worktree() {
  local cwd
  cwd=$(printf '%s' "$input" | /usr/bin/jq -r '.cwd // empty' 2>/dev/null)
  [ -n "$cwd" ] || cwd="$PWD"
  local git_dir common_dir
  git_dir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null) || return 1
  common_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  [ "$git_dir" != "$common_dir" ]
}

# Split on the shell operators that separate commands: fold the two-character
# operators onto ';' first, then turn every separator into a newline. Quoting is
# not honoured; an over-split segment can only cost a missed match, never a
# wrong block.
# shellcheck disable=SC2020 # three separator characters, all folded to newline
segments=$(printf '%s' "$command_text" | sed -E 's/(\|\||&&)/;/g' | tr ';|&' '\n\n\n')

while IFS= read -r segment; do
  [ -n "$segment" ] || continue
  # shellcheck disable=SC2206
  TOK=($segment)
  [ "${#TOK[@]}" -gt 0 ] || continue
  parse_git_segment || continue

  if adds_worktree_on_main; then
    deny "Blocked: creating a worktree on 'main' locks the branch for every other checkout of this repo. Branch from main instead (git worktree add <path> -b <type>/TSW<n>-<description> main)."
  fi

  if switches_to_main && in_linked_worktree; then
    deny "Blocked: this session runs in a linked worktree, and checking out 'main' here locks the branch for every other checkout of the repo — the main checkout can no longer switch to it. Read main without taking it (git log main, git diff main...HEAD), or work on a feature branch."
  fi
done <<EOF
$segments
EOF

exit 0
