#!/usr/bin/env bash
# preview-rainbow.sh — print rainbow palette swatches for claude themes
# usage: ./preview-rainbow.sh [theme-name]
#   theme-name: operandi | tinted | everforest | kanagawa | tokyo (default: all)

set -euo pipefail
cd "$(dirname "$0")/.."

show_theme() {
  local file="$1" label="$2"
  local filepath="themes/claude/${file}"

  [ ! -f "$filepath" ] && { echo "SKIP: $filepath" >&2; return; }

  python3 -c "
import json
with open('$filepath') as f:
    d = json.load(f).get('overrides', {})

tokens = {k:v for k,v in d.items() if k.startswith('rainbow_')}

print()
print('  $label')
print('  ' + '-' * 52)

sample = 'Hello rainbow'

# spectrum order: red -> violet
spectrum = ['rainbow_red','rainbow_orange','rainbow_yellow','rainbow_green','rainbow_blue','rainbow_indigo','rainbow_violet']

def parse_color(v):
    if v.startswith('rgb('):
        vals = [int(x) for x in v.replace('rgb(','').replace(')','').split(',')]
        return tuple(vals), v
    else:
        r = int(v[1:3],16); g = int(v[3:5],16); b = int(v[5:7],16)
        return (r,g,b), v

# display order: bases in spectrum, then shimmers in same order
order = []
for b in spectrum:
    order.append(b)
    shimmer = b + '_shimmer'
    if shimmer in tokens:
        order.append(shimmer)

for k in order:
    v = tokens[k]
    (r,g,b), display = parse_color(v)
    block = f'\033[48;2;{r};{g};{b}m  \033[0m'
    fg    = f'\033[38;2;{r};{g};{b}m'
    print(f'  {block}  {k:34s}  {display}  |  {fg}{sample}\033[0m')

# rainbow cycling line: each char colored by next base color
cycle_colors = []
for b in spectrum:
    v = tokens[b]
    (r,g,b), _ = parse_color(v)
    cycle_colors.append((r,g,b))

# Build rainbow text: palette blocks + sample
parts = []
for (r,g,b) in cycle_colors:
    parts.append(f'\033[48;2;{r};{g};{b}m  \033[0m')
blocks = ''.join(parts)

rainbow_text = 'noomz-themes'
colored = []
for i, ch in enumerate(rainbow_text):
    (r,g,b) = cycle_colors[i % len(cycle_colors)]
    colored.append(f'\033[38;2;{r};{g};{b}m{ch}\033[0m')
result = ''.join(colored)
label = 'rainbow'
print(f'  {blocks}  {label:>34s}           {result}')
print()
"
}

# theme registry: alias -> (filename, label)
# ordered list to preserve iteration order
THEME_SPECS=(
  "operandi|modus-operandi.json|MODUS OPERANDI"
  "tinted|modus-operandi-tinted.json|MODUS OPERANDI TINTED"
  "everforest|everforest-light.json|EVERFOREST LIGHT"
  "kanagawa|kanagawa.json|KANAGAWA"
  "tokyo|tokyo-night-day.json|TOKYO NIGHT DAY"
)

show_all() {
  for spec in "${THEME_SPECS[@]}"; do
    IFS='|' read -r _ file label <<< "$spec"
    show_theme "$file" "$label"
  done
}

show_one() {
  local alias="$1"
  for spec in "${THEME_SPECS[@]}"; do
    IFS='|' read -r a file label <<< "$spec"
    if [ "$a" = "$alias" ]; then
      show_theme "$file" "$label"
      return 0
    fi
  done
  echo "Unknown theme: $alias" >&2
  echo -n "Available: " >&2
  for spec in "${THEME_SPECS[@]}"; do
    IFS='|' read -r a _ _ <<< "$spec"
    echo -n "$a " >&2
  done
  echo >&2
  exit 1
}

if [ $# -eq 0 ]; then show_all; else show_one "$1"; fi
