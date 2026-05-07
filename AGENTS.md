# AGENTS.md

Guidance for coding agents working in this repo.

## Project purpose

`noomz-themes` stores high-contrast light Modus Operandi themes for agent CLIs:

- Claude Code themes: `themes/claude/*.json`
- pi.dev themes: `themes/pi.dev/*.json`
- Hermes Agent themes: `themes/hermes/*.yaml`

Keep palette changes consistent across supported CLIs when possible.

## Repo layout

```text
themes/
  claude/     Claude Code JSON themes
  pi.dev/     pi.dev JSON themes
  hermes/     Hermes YAML skins
scripts/
  install.sh
  validate-claude-theme.py
```

## Validation

After changing Claude Code themes, run:

```sh
python3 scripts/validate-claude-theme.py themes/claude/*.json
```

For stricter CI-like validation, run:

```sh
python3 scripts/validate-claude-theme.py --strict-tokens themes/claude/*.json
```

After changing install behavior, run or inspect:

```sh
bash scripts/install.sh
```

## Style rules

- Preserve existing theme names and slugs unless user explicitly asks for rename.
- Prefer exact documented token names for Claude Code theme overrides.
- Keep color values valid hex strings.
- Avoid broad palette rewrites unless requested; make small, traceable changes.
- When adding new variants, add matching README install/docs entries.
- Keep JSON/YAML formatting stable and human-readable.

## Safety notes

- Do not edit user home config files (`~/.claude`, `~/.pi`, `~/.hermes`) unless user asks.
- Do not kill terminal, Claude, pi, Hermes, cmux, or other running agent processes for theme reloads.
- Theme runtime smoke tests should use temporary obvious colors, then revert before finishing.
