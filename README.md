# noomz-themes

High-contrast light Modus Operandi themes for agent CLIs.

Currently included:

- Claude Code: `themes/claude/modus-operandi.json`
- Claude Code tinted variant: `themes/claude/modus-operandi-tinted.json` (uses canonical `modus-operandi-tinted` palette values from https://protesilaos.com/emacs/modus-themes-colors)
- pi.dev: `themes/pi.dev/modus-operandi.json`
- pi.dev tinted variant: `themes/pi.dev/modus-operandi-tinted.json`
- Hermes Agent: `themes/hermes/modus-operandi.yaml`
- Hermes Agent tinted variant: `themes/hermes/modus-operandi-tinted.yaml`

The palette keeps the light Modus Operandi feel while darkening low-contrast text, especially collapsed-output hints, file/link paths, dim metadata, neutral borders, and selection surfaces.

## Install

### Claude Code

```sh
mkdir -p ~/.claude/themes
cp themes/claude/*.json ~/.claude/themes/
```

Then select one inside Claude Code:

```text
/theme modus-operandi
/theme modus-operandi-tinted
```

### pi.dev

Preferred custom theme location:

```sh
mkdir -p ~/.pi/agent/themes
cp themes/pi.dev/*.json ~/.pi/agent/themes/
```

Then set `theme` to `modus-operandi` or `modus-operandi-tinted` in `~/.pi/agent/settings.json`.

### Hermes Agent

```sh
mkdir -p ~/.hermes/skins
cp themes/hermes/*.yaml ~/.hermes/skins/
```

Then select one inside Hermes:

```text
/skin modus-operandi
/skin modus-operandi-tinted
```

To make it the default, set:

```sh
hermes config set display.skin modus-operandi
```

## Claude Code validation

Claude Code custom themes use the documented `name`, `base`, and `overrides` contract. Unknown override tokens are silently ignored by Claude Code, so this repo includes a validator to catch schema mistakes, invalid color syntax, and accidental undocumented tokens.

Validate the repo themes:

```sh
python3 scripts/validate-claude-theme.py themes/claude/*.json
```

Validate the active installed Claude Code copies:

```sh
python3 scripts/validate-claude-theme.py ~/.claude/themes/modus-operandi*.json
```

Validate all known active copies, including CCS-managed instances:

```sh
python3 scripts/validate-claude-theme.py \
  ~/.claude/themes/modus-operandi*.json \
  ~/.ccs/instances/work/themes/modus-operandi*.json \
  ~/.ccs/instances/personal/themes/modus-operandi*.json \
  themes/claude/*.json
```

For CI-like checks, fail on undocumented tokens too:

```sh
python3 scripts/validate-claude-theme.py --strict-tokens themes/claude/*.json
```

The active Claude Code preference should select the custom theme slug:

```sh
python3 - <<'PY'
import json, pathlib
print(json.loads(pathlib.Path('~/.claude/settings.json').expanduser().read_text()).get('theme'))
PY
```

Expected output:

```text
custom:modus-operandi
```

If CCS manages separate Claude instances, also confirm the intended theme slug in `~/.ccs/config.yaml` if that config is used by the instance.

### Runtime smoke testing

Claude Code reloads theme file edits from `~/.claude/themes/`. For disputed UI areas, temporarily set a known token to an obvious value, save the file, confirm the running Claude Code session changes, then revert it.

Useful token probes:

- collapsed hints: `inactive`, `subtle`
- picker/autocomplete/selection: `suggestion`
- input shell mode: `bashBorder`
- permission prompts: `permission`
- plan mode: `planMode`
- fullscreen message panels: `userMessageBackground`, `bashMessageBackgroundColor`, `messageActionsBackground`

Claude Code does not control the terminal application's canvas/background. If the whole terminal background is too bright, adjust the terminal emulator profile instead, or use an ANSI-based Claude theme base such as `light-ansi` together with the terminal ANSI palette and background color. If using cmux or another terminal wrapper, identify the host terminal profile before changing colors; do not kill production cmux processes just to force a reload.

## Files

```text
themes/
  claude/modus-operandi.json
  claude/modus-operandi-tinted.json
  pi.dev/modus-operandi.json
  pi.dev/modus-operandi-tinted.json
  hermes/modus-operandi.yaml
  hermes/modus-operandi-tinted.yaml
scripts/
  install.sh
  validate-claude-theme.py
```

## License

MIT
