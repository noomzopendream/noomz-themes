#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

mkdir -p "$HOME/.claude/themes"
cp "$ROOT/themes/claude/modus-operandi.json" "$HOME/.claude/themes/modus-operandi.json"

mkdir -p "$HOME/.pi/agent/themes"
cp "$ROOT/themes/pi.dev/modus-operandi.json" "$HOME/.pi/agent/themes/modus-operandi.json"

mkdir -p "$HOME/.hermes/skins"
cp "$ROOT/themes/hermes/modus-operandi.yaml" "$HOME/.hermes/skins/modus-operandi.yaml"

printf '%s
' "Installed Modus Operandi themes for Claude Code, pi.dev, and Hermes Agent."
printf '%s
' "Activate manually where needed: Claude /theme modus-operandi, Hermes /skin modus-operandi, pi.dev settings theme=modus-operandi."
