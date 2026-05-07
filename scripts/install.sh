#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
CLAUDE_THEME="$ROOT/themes/claude/modus-operandi.json"
VALIDATOR="$ROOT/scripts/validate-claude-theme.py"

if [ "${STRICT:-0}" = "1" ]; then
  python3 "$VALIDATOR" --strict-tokens "$CLAUDE_THEME"
else
  python3 "$VALIDATOR" "$CLAUDE_THEME"
fi

mkdir -p "$HOME/.claude/themes"
cp "$CLAUDE_THEME" "$HOME/.claude/themes/modus-operandi.json"

mkdir -p "$HOME/.pi/agent/themes"
cp "$ROOT/themes/pi.dev/modus-operandi.json" "$HOME/.pi/agent/themes/modus-operandi.json"

mkdir -p "$HOME/.hermes/skins"
cp "$ROOT/themes/hermes/modus-operandi.yaml" "$HOME/.hermes/skins/modus-operandi.yaml"

printf '%s\n' "Installed Modus Operandi themes for Claude Code, pi.dev, and Hermes Agent."
printf '%s\n' "Activate manually where needed: Claude /theme modus-operandi, Hermes /skin modus-operandi, pi.dev settings theme=modus-operandi."
