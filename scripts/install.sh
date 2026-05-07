#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CLAUDE_THEMES_DIR="$ROOT/themes/claude"
PI_THEMES_DIR="$ROOT/themes/pi.dev"
HERMES_SKINS_DIR="$ROOT/themes/hermes"
VALIDATOR="$ROOT/scripts/validate-claude-theme.py"

if [ "${STRICT:-0}" = "1" ]; then
  python3 "$VALIDATOR" --strict-tokens "$CLAUDE_THEMES_DIR"/*.json
else
  python3 "$VALIDATOR" "$CLAUDE_THEMES_DIR"/*.json
fi

mkdir -p "$HOME/.claude/themes"
for theme in "$CLAUDE_THEMES_DIR"/*.json; do
  cp "$theme" "$HOME/.claude/themes/$(basename "$theme")"
done

mkdir -p "$HOME/.pi/agent/themes"
for theme in "$PI_THEMES_DIR"/*.json; do
  cp "$theme" "$HOME/.pi/agent/themes/$(basename "$theme")"
done

mkdir -p "$HOME/.hermes/skins"
for skin in "$HERMES_SKINS_DIR"/*.yaml; do
  cp "$skin" "$HOME/.hermes/skins/$(basename "$skin")"
done

printf '%s\n' "Installed Modus Operandi themes for Claude Code, pi.dev, and Hermes Agent."
printf '%s\n' "Claude variants: modus-operandi, modus-operandi-tinted. Activate with /theme <variant>."
printf '%s\n' "Hermes variants: modus-operandi, modus-operandi-tinted. Activate with /skin <variant>."
printf '%s\n' "pi.dev variants: set theme to modus-operandi or modus-operandi-tinted in ~/.pi/agent/settings.json."
