# noomz-themes

High-contrast light Modus Operandi themes for agent CLIs.

Currently included:

- Claude Code: `themes/claude/modus-operandi.json`
- pi.dev: `themes/pi.dev/modus-operandi.json`
- Hermes Agent: `themes/hermes/modus-operandi.yaml`

The palette keeps the light Modus Operandi feel while darkening low-contrast text, especially collapsed-output hints, file/link paths, dim metadata, neutral borders, and selection surfaces.

## Install

### Claude Code

```sh
mkdir -p ~/.claude/themes
cp themes/claude/modus-operandi.json ~/.claude/themes/modus-operandi.json
```

Then select it inside Claude Code:

```text
/theme modus-operandi
```

### pi.dev

Preferred custom theme location:

```sh
mkdir -p ~/.pi/agent/themes
cp themes/pi.dev/modus-operandi.json ~/.pi/agent/themes/modus-operandi.json
```

Then set `theme` to `modus-operandi` in `~/.pi/agent/settings.json`.

### Hermes Agent

```sh
mkdir -p ~/.hermes/skins
cp themes/hermes/modus-operandi.yaml ~/.hermes/skins/modus-operandi.yaml
```

Then select it inside Hermes:

```text
/skin modus-operandi
```

To make it the default, set:

```sh
hermes config set display.skin modus-operandi
```

## Files

```text
themes/
  claude/modus-operandi.json
  pi.dev/modus-operandi.json
  hermes/modus-operandi.yaml
scripts/
  install.sh
```

## License

MIT
