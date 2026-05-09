#!/bin/bash

# PostToolUse hook to track working directory changes from Bash commands
# Writes current directory to a state file for the status line to read

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')
exit_code=$(echo "$input" | jq -r '.tool_response.exit_code // 0')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# State file per session to handle multiple sessions
state_file="/tmp/.claude-cwd-${session_id}"

# Get the initial/fallback directory from the hook input
initial_cwd=$(echo "$input" | jq -r '.cwd // empty')

# Read current tracked directory, default to initial cwd
if [ -f "$state_file" ]; then
    current_dir=$(cat "$state_file")
else
    current_dir="$initial_cwd"
    echo "$current_dir" > "$state_file"
fi

# Only process if command succeeded
[ "$exit_code" -ne 0 ] && exit 0

# Function to resolve a path relative to current directory
resolve_path() {
    local target="$1"
    local base="$2"

    # Expand ~ to home
    target="${target/#\~/$HOME}"

    # If absolute, use as-is
    if [[ "$target" == /* ]]; then
        echo "$target"
    else
        # Relative path - combine with base
        echo "$base/$target"
    fi
}

# Extract cd commands from the bash command
# Handle patterns: cd path, cd path && ..., cd path; ...
extract_last_cd() {
    local cmd="$1"
    local last_cd=""

    # Split by && and ; and process each part
    while IFS= read -r part; do
        # Trim whitespace
        part=$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Check if this part is a cd command
        if [[ "$part" =~ ^cd[[:space:]]+(.+)$ ]]; then
            last_cd="${BASH_REMATCH[1]}"
            # Remove any trailing && or ; or whitespace
            last_cd=$(echo "$last_cd" | sed 's/[[:space:]]*[&;|].*$//' | sed 's/[[:space:]]*$//')
            # Remove quotes if present
            last_cd=$(echo "$last_cd" | sed "s/^['\"]//;s/['\"]$//")
        fi
    done < <(echo "$cmd" | tr ';&' '\n')

    echo "$last_cd"
}

# Only track cd if it's a standalone command (not part of a compound command)
# Compound commands with &&, ;, || are temporary and get reset by Claude Code
is_compound_command() {
    local cmd="$1"
    [[ "$cmd" == *"&&"* ]] || [[ "$cmd" == *";"* ]] || [[ "$cmd" == *"||"* ]]
}

# Skip tracking for compound commands - the cd is temporary
if is_compound_command "$command"; then
    exit 0
fi

# Find the last cd in the command
cd_target=$(extract_last_cd "$command")

if [ -n "$cd_target" ]; then
    # Resolve the new path
    new_dir=$(resolve_path "$cd_target" "$current_dir")

    # Normalize the path (resolve . and ..)
    new_dir=$(cd "$new_dir" 2>/dev/null && pwd || echo "$new_dir")

    # Update state file
    echo "$new_dir" > "$state_file"
fi

exit 0
