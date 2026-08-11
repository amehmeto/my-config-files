# Tab color randomizer (iTerm2 + cmux)
# Picks a random color ensuring visual distinction from the last 3 used
# - iTerm2: colors the tab via the proprietary SetColors escape sequence
# - cmux:   colors the workspace via `cmux workspace-action set-color`
# Usage: `rc` to re-roll the tab color on the fly

_tab_colors=(
  "150;90;90"    # coral
  "80;120;85"    # green
  "70;100;145"   # blue
  "115;90;130"   # purple
  "145;115;80"   # orange
  "70;130;120"   # teal
  "145;130;80"   # yellow
  "140;85;120"   # pink
  "90;95;130"    # slate
  "120;80;80"    # burgundy
  "85;130;100"   # mint
  "150;100;100"  # salmon
  "80;90;120"    # navy
  "130;120;90"   # olive
  "100;85;135"   # indigo
  "95;115;105"   # sage
  "130;95;85"    # terracotta
  "85;105;130"   # steel blue
  "140;110;95"   # copper
  "90;120;130"   # dusty cyan
  "125;100;115"  # mauve
  "110;130;95"   # moss
  "135;95;110"   # dusty rose
  "100;110;85"   # khaki
  "115;105;140"  # lavender
  "130;130;100"  # sand
  "95;85;110"    # plum
  "110;95;80"    # brown
  "80;115;115"   # sea green
  "140;120;110"  # beige
)

_tab_color_history_file="$HOME/.iterm_color_history"

# Minimum squared RGB distance to consider two colors "distinct"
# ~60 in Euclidean RGB space — filters out close pairs like coral/salmon
_tab_color_min_dist_sq=3600

_apply_tab_color() {
  local r g b
  IFS=';' read -r r g b <<< "$1"
  if [[ -n "$CMUX_WORKSPACE_ID" ]]; then
    CMUX_QUIET=1 cmux workspace-action --action set-color \
      --color "$(printf '#%02x%02x%02x' "$r" "$g" "$b")" >/dev/null 2>&1
  elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    printf '\e]1337;SetColors=tab=%02x%02x%02x\a' "$r" "$g" "$b"
  fi
}

recolor() {
  local -a recent=() candidates=()
  local cr cg cb pr pg pb dr dg db distinct
  local i pick picked tmp

  # Load recent colors from history
  if [[ -f "$_tab_color_history_file" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] && recent+=("$line")
    done < "$_tab_color_history_file"
  fi

  # Build list of candidate indices that are distinct from all recent colors
  for (( i = 1; i <= ${#_tab_colors[@]}; i++ )); do
    distinct=1
    IFS=';' read -r cr cg cb <<< "${_tab_colors[$i]}"
    for past in "${recent[@]}"; do
      IFS=';' read -r pr pg pb <<< "$past"
      dr=$((cr - pr)) dg=$((cg - pg)) db=$((cb - pb))
      if (( dr * dr + dg * dg + db * db < _tab_color_min_dist_sq )); then
        distinct=0
        break
      fi
    done
    (( distinct )) && candidates+=($i)
  done

  # Fallback: if too few distinct candidates, use the full palette
  if (( ${#candidates[@]} < 5 )); then
    candidates=()
    for (( i = 1; i <= ${#_tab_colors[@]}; i++ )); do
      candidates+=($i)
    done
  fi

  # Pick random from candidates
  if (( ${#candidates[@]} == 0 )); then
    return 1
  fi
  pick=${candidates[$((RANDOM % ${#candidates[@]} + 1))]}
  picked=${_tab_colors[$pick]}

  # Append to history and keep only the last 3
  echo "$picked" >> "$_tab_color_history_file"
  tmp=$(tail -n 3 "$_tab_color_history_file")
  echo "$tmp" > "$_tab_color_history_file"

  _apply_tab_color "$picked"
}

alias rc='recolor'

# In cmux, a workspace hosts several shells (splits/panes): only color it
# if it has no color yet, so a new split doesn't re-roll the whole workspace.
_cmux_workspace_has_color() {
  local color
  color=$(CMUX_QUIET=1 cmux list-workspaces --json --id-format uuids 2>/dev/null \
    | jq -r --arg id "$CMUX_WORKSPACE_ID" \
        '.workspaces[] | select(.id == $id) | .custom_color')
  [[ -n "$color" && "$color" != "null" ]]
}

# Set tab color on shell startup
if [[ -n "$CMUX_WORKSPACE_ID" ]]; then
  _cmux_workspace_has_color || recolor
elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  recolor
fi
