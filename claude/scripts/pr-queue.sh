#!/usr/bin/env bash
set -euo pipefail

# List the open PRs of this repository, smallest diff first, so the cheapest
# review comes first.
#
# Usage:
#   ./scripts/pr-queue.sh              Colored terminal output (ANSI + URLs)
#   ./scripts/pr-queue.sh --markdown   Markdown table (used by /pr-queue)

FORMAT="ansi"
if [[ "${1:-}" == "--markdown" ]]; then
  FORMAT="markdown"
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--markdown]" >&2
  exit 2
fi

GREEN_SQUARE="🟩"
RED_SQUARE="🟥"
EMPTY_SQUARE="⬜"
BAR_SLOTS=5
TITLE_WIDTH=46
BACKTICK='`'

COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_DIM='\033[2m'
COLOR_BOLD='\033[1m'
COLOR_NC='\033[0m'

# GitHub's diffstat bar: BAR_SLOTS squares split proportionally between
# additions and deletions, each share floored, the remainder left grey — a
# +620/-25 PR shows four green and one grey, exactly like the PR header.
render_bar() {
  local additions=$1 deletions=$2
  local total=$((additions + deletions))
  local green=0 red=0 slot

  if [[ $total -gt 0 ]]; then
    green=$((additions * BAR_SLOTS / total))
    red=$((deletions * BAR_SLOTS / total))
  fi

  for ((slot = 0; slot < BAR_SLOTS; slot++)); do
    if [[ $slot -lt $green ]]; then
      printf '%s' "$GREEN_SQUARE"
    elif [[ $slot -lt $((green + red)) ]]; then
      printf '%s' "$RED_SQUARE"
    else
      printf '%s' "$EMPTY_SQUARE"
    fi
  done
}

truncate_title() {
  local title=$1
  if [[ ${#title} -gt $TITLE_WIDTH ]]; then
    printf '%s…' "${title:0:$((TITLE_WIDTH - 1))}"
  else
    printf '%s' "$title"
  fi
}

escape_pipes() {
  printf '%s' "${1//|/\\|}"
}

PR_ROWS=$(gh pr list --state open --limit 100 \
  --json number,title,url,additions,deletions,changedFiles,isDraft \
  --jq 'sort_by(.additions + .deletions)[]
        | [.number, .additions, .deletions, .changedFiles, (if .isDraft then "draft" else "ready" end), .url, .title]
        | @tsv')

if [[ -z "$PR_ROWS" ]]; then
  echo "No open PR."
  exit 0
fi

if [[ "$FORMAT" == "markdown" ]]; then
  echo "| # | LoC | Files | Diff | PR |"
  echo "| ---: | ---: | ---: | :--- | :--- |"
else
  printf "${COLOR_BOLD}%3s  %-5s %-6s %-12s%-13s %-${TITLE_WIDTH}s %s${COLOR_NC}\n" \
    "" "LoC" "FILES" "SPLIT" "+ / -" "TITLE" "LINK"
fi

RANK=0
while IFS=$'\t' read -r number additions deletions files draft url title; do
  RANK=$((RANK + 1))
  loc=$((additions + deletions))
  bar=$(render_bar "$additions" "$deletions")
  [[ "$draft" == "draft" ]] && title="[draft] $title"

  if [[ "$FORMAT" == "markdown" ]]; then
    printf '| %d | %d | %d | %s %s+%d -%d%s | [#%d — %s](%s) |\n' \
      "$RANK" "$loc" "$files" "$bar" "$BACKTICK" "$additions" "$deletions" "$BACKTICK" \
      "$number" "$(escape_pipes "$title")" "$url"
  else
    printf "%3d. %-5d %-6d %s  ${COLOR_GREEN}+%-5d${COLOR_NC} ${COLOR_RED}-%-5d${COLOR_NC} %-${TITLE_WIDTH}s ${COLOR_DIM}%s${COLOR_NC}\n" \
      "$RANK" "$loc" "$files" "$bar" "$additions" "$deletions" \
      "$(truncate_title "$title")" "$url"
  fi
done <<<"$PR_ROWS"
