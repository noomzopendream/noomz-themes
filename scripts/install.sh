#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CLAUDE_THEMES_DIR="$ROOT/themes/claude"
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
cp "$ROOT/themes/pi.dev/modus-operandi.json" "$HOME/.pi/agent/themes/modus-operandi.json"

mkdir -p "$HOME/.hermes/skins"
cp "$ROOT/themes/hermes/modus-operandi.yaml" "$HOME/.hermes/skins/modus-operandi.yaml"

printf '%s\n' "Installed Modus Operandi themes for Claude Code, pi.dev, and Hermes Agent."
printf '%s\n' "Claude variants: modus-operandi, modus-operandi-tinted. Activate with /theme <variant>."
printf '%s\n' "Activate manually where needed: Hermes /skin modus-operandi, pi.dev settings theme=modus-operandi."
