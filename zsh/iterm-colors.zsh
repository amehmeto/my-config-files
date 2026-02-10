# iTerm2 tab color randomizer
# Picks a random color from predefined list, avoiding repeats

colors=(
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

last_color_file="$HOME/.iterm_last_color"
last_index=-1
[[ -f "$last_color_file" ]] && last_index=$(<"$last_color_file")

# Pick a random index different from last
new_index=$((RANDOM % ${#colors[@]}))
while [[ $new_index -eq $last_index ]]; do
  new_index=$((RANDOM % ${#colors[@]}))
done
echo "$new_index" > "$last_color_file"

picked=${colors[$new_index]}
IFS=';' read -r r g b <<< "$picked"
echo -e "\033]6;1;bg;red;brightness;$r\a"
echo -e "\033]6;1;bg;green;brightness;$g\a"
echo -e "\033]6;1;bg;blue;brightness;$b\a"
