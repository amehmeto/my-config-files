# iTerm2 tab color randomizer
# Picks a random color ensuring visual distinction from the last 3 used
# Usage: `rc` to re-roll the tab color on the fly

_iterm_colors=(
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

_iterm_history_file="$HOME/.iterm_color_history"

# Minimum squared RGB distance to consider two colors "distinct"
# ~60 in Euclidean RGB space — filters out close pairs like coral/salmon
_iterm_min_dist_sq=3600

recolor() {
  local -a recent=() candidates=()
  local cr cg cb pr pg pb dr dg db distinct
  local i pick picked tmp r g b

  # Load recent colors from history
  if [[ -f "$_iterm_history_file" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] && recent+=("$line")
    done < "$_iterm_history_file"
  fi

  # Build list of candidate indices that are distinct from all recent colors
  for (( i = 1; i <= ${#_iterm_colors[@]}; i++ )); do
    distinct=1
    IFS=';' read -r cr cg cb <<< "${_iterm_colors[$i]}"
    for past in "${recent[@]}"; do
      IFS=';' read -r pr pg pb <<< "$past"
      dr=$((cr - pr)) dg=$((cg - pg)) db=$((cb - pb))
      if (( dr * dr + dg * dg + db * db < _iterm_min_dist_sq )); then
        distinct=0
        break
      fi
    done
    (( distinct )) && candidates+=($i)
  done

  # Fallback: if too few distinct candidates, use the full palette
  if (( ${#candidates[@]} < 5 )); then
    candidates=()
    for (( i = 1; i <= ${#_iterm_colors[@]}; i++ )); do
      candidates+=($i)
    done
  fi

  # Pick random from candidates
  pick=${candidates[$((RANDOM % ${#candidates[@]} + 1))]}
  picked=${_iterm_colors[$pick]}

  # Append to history and keep only the last 3
  echo "$picked" >> "$_iterm_history_file"
  tmp=$(tail -n 3 "$_iterm_history_file")
  echo "$tmp" > "$_iterm_history_file"

  # Apply color to iTerm2 tab
  IFS=';' read -r r g b <<< "$picked"
  printf "\033]6;1;bg;red;brightness;%s\a" "$r"
  printf "\033]6;1;bg;green;brightness;%s\a" "$g"
  printf "\033]6;1;bg;blue;brightness;%s\a" "$b"
}

alias rc='recolor'

# Set tab color on shell startup
recolor
