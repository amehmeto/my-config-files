#!/usr/bin/env bash
#
# Free disk by deleting node_modules inside stale git worktrees.
#
# Every worktree under .claude/worktrees/ installs its own full node_modules —
# about 1.8 GB each. At 139 worktrees that was 226 GB, a quarter of the disk,
# on a machine sitting at 98% full.
#
# This deletes node_modules and nothing else: no code, no branch, no worktree,
# no uncommitted work. `npm ci` rebuilds any directory it removes.
#
# Guards, because other sessions may be live in these directories:
#   - skip a worktree touched in the last KEEP_DAYS days (default 2)
#   - skip a worktree with uncommitted changes
#   - skip the worktree this script is running from
#
# Usage:
#   bash scripts/purge-worktree-node-modules.sh              # dry run
#   APPLY=true bash scripts/purge-worktree-node-modules.sh   # delete
#
# Must stay bash 3.2 / BSD compatible.
set -euo pipefail

KEEP_DAYS="${KEEP_DAYS:-2}"
APPLY="${APPLY:-false}"

# --git-common-dir points at the MAIN checkout's .git even when this runs from
# inside a worktree, which is where the worktrees directory lives.
if [ -z "${WORKTREES_ROOT:-}" ]; then
  common_dir="$(git rev-parse --path-format=absolute --git-common-dir 2> /dev/null || true)"
  [ -n "$common_dir" ] || {
    echo "not inside a git repository, and WORKTREES_ROOT is unset" >&2
    exit 1
  }
  WORKTREES_ROOT="$(dirname "$common_dir")/.claude/worktrees"
fi

[ -d "$WORKTREES_ROOT" ] || {
  echo "no worktrees directory at $WORKTREES_ROOT — nothing to do"
  exit 0
}

self="$(pwd -P)"
total_kb=0
purged=0
kept=0

for wt in "$WORKTREES_ROOT"/*/; do
  wt="${wt%/}"
  name="$(basename "$wt")"
  [ -d "$wt/node_modules" ] || continue

  if [ "$(cd "$wt" && pwd -P)" = "$self" ]; then
    echo "keep   $name — this is the current working directory"
    kept=$((kept + 1))
    continue
  fi

  # A recent mtime is the cheapest signal that a session is live in there.
  if [ -n "$(find "$wt" -maxdepth 1 -mtime -"$KEEP_DAYS" -print -quit 2> /dev/null)" ]; then
    echo "keep   $name — touched in the last $KEEP_DAYS day(s)"
    kept=$((kept + 1))
    continue
  fi

  # Uncommitted work means somebody is mid-task: leave the whole tree alone.
  if [ -n "$(git -C "$wt" status --porcelain 2> /dev/null)" ]; then
    echo "keep   $name — uncommitted changes"
    kept=$((kept + 1))
    continue
  fi

  size_kb="$(du -sk "$wt/node_modules" 2> /dev/null | cut -f1)"
  case "$size_kb" in '' | *[!0-9]*) size_kb=0 ;; esac
  total_kb=$((total_kb + size_kb))
  purged=$((purged + 1))

  if [ "$APPLY" = "true" ]; then
    rm -rf "$wt/node_modules"
    echo "purge  $name — $((size_kb / 1024)) MB freed"
  else
    echo "would  $name — $((size_kb / 1024)) MB"
  fi
done

echo
if [ "$APPLY" = "true" ]; then
  echo "$purged purged, $kept kept — $((total_kb / 1024 / 1024)) GB freed"
else
  echo "$purged purgeable, $kept kept — $((total_kb / 1024 / 1024)) GB recoverable"
  echo "dry run — re-run with APPLY=true to delete"
fi
