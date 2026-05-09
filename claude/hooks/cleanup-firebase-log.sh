#!/bin/bash

# PostToolUse hook: remove firebase-debug.log files created by Firebase MCP plugin
# The plugin's logger hardcodes process.cwd() and ignores FIREBASE_CLI_LOG_FILE

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')

[ -z "$cwd" ] && exit 0

for f in "$cwd"/firebase-debug.log "$cwd"/firebase-debug.*.log; do
    [ -f "$f" ] && rm -f "$f"
done

exit 0
