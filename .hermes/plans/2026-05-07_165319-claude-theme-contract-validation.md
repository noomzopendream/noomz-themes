# Plan: Systematically verify Claude Code theme contract

## Goal

Make the Claude theme work predictable and docs-aligned by adding a systematic validation workflow for `themes/claude/modus-operandi.json` and the active installed copies.

The validator should answer:

1. Does the theme file match the Claude Code documented schema?
2. Are all override tokens documented / intentionally accepted?
3. Are color values syntactically valid according to docs?
4. Is the active Claude Code preference actually selecting this custom theme?
5. Which remaining visual issues are outside Claude Code theme control and belong to the terminal emulator palette?

## Current context

Docs read from:

https://code.claude.com/docs/en/terminal-config.md

Relevant Claude Code contract from docs:

- Custom themes require Claude Code v2.1.118+.
- Custom themes live in `~/.claude/themes/`.
- Filename without `.json` is the slug.
- Selecting the theme stores `custom:<slug>` as the theme preference.
- Theme file has three optional top-level fields:
  - `name`: string
  - `base`: one of `dark`, `light`, `dark-daltonized`, `light-daltonized`, `dark-ansi`, `light-ansi`
  - `overrides`: object mapping token names to color values
- Accepted color syntaxes:
  - `#rrggbb`
  - `#rgb`
  - `rgb(r,g,b)`
  - `ansi256(n)`
  - `ansi:<name>` for standard ANSI color names
- Unknown tokens and invalid colors are ignored, so typos do not break rendering but silently do nothing.
- Claude Code watches `~/.claude/themes/` and reloads file edits.
- Claude Code does not control the terminal application's own color scheme.

Current active paths:

- `/Users/noomz/.claude/themes/modus-operandi.json`
- `/Users/noomz/.ccs/instances/work/themes/modus-operandi.json`
- `/Users/noomz/.ccs/instances/personal/themes/modus-operandi.json`
- `/Users/noomz/Projects/Opensources/noomz-themes/themes/claude/modus-operandi.json`

Current active preference already observed:

- `/Users/noomz/.claude/settings.json` has `"theme": "custom:modus-operandi"`

Current schema has already been fixed from the legacy/wrong `colors` object to the documented `overrides` object.

Current base has already been changed to:

- `light-daltonized`

Static validation already found likely ignored tokens:

- `background`
- `chromeYellow`
- `clawd_background`
- `clawd_body`
- `diffAddedWordDimmed`
- `diffRemovedWordDimmed`
- `professionalBlue`

## Proposed approach

Add a repo validator script and document the validation workflow. Keep it read-only by default. Use it to validate both repo theme files and installed active theme files.

Do not try to solve terminal background glare solely through Claude Code theme tokens unless docs confirm a token controls it. The docs explicitly say Claude Code does not control the terminal application's own color scheme.

## Step-by-step plan

### 1. Add a Claude theme validator script

Create:

- `/Users/noomz/Projects/Opensources/noomz-themes/scripts/validate-claude-theme.py`

Responsibilities:

- Accept one or more JSON theme paths as CLI args.
- Parse JSON.
- Validate top-level object.
- Validate allowed top-level keys:
  - `name`
  - `base`
  - `overrides`
- Fail on legacy keys that cause confusion:
  - `colors`
  - maybe `id`
- Validate `name` if present is string.
- Validate `base` if present is one of:
  - `dark`
  - `light`
  - `dark-daltonized`
  - `light-daltonized`
  - `dark-ansi`
  - `light-ansi`
- Validate `overrides` if present is object.
- Validate override values are strings matching documented color syntax.
- Warn on unknown tokens because Claude ignores them silently.
- Exit non-zero on hard schema/color errors.
- Exit zero with warnings for unknown tokens unless `--strict-tokens` is passed.

### 2. Encode documented token allowlist

Use token groups from docs:

Text and accent:

- `claude`
- `text`
- `inverseText`
- `inactive`
- `subtle`
- `suggestion`
- `permission`
- `remember`

Status:

- `success`
- `error`
- `warning`
- `merged`

Input box and mode indicators:

- `promptBorder`
- `planMode`
- `autoAccept`
- `bashBorder`
- `ide`
- `fastMode`

Diff:

- `diffAdded`
- `diffRemoved`
- `diffAddedDimmed`
- `diffRemovedDimmed`
- `diffAddedWord`
- `diffRemovedWord`

Fullscreen mode:

- `userMessageBackground`
- `userMessageBackgroundHover`
- `messageActionsBackground`
- `bashMessageBackgroundColor`
- `memoryBackgroundColor`
- `selectionBg`

Usage meter and labels:

- `rate_limit_fill`
- `rate_limit_empty`
- `briefLabelYou`
- `briefLabelClaude`

Documented shimmer variants:

- `claudeShimmer`
- `warningShimmer`
- `permissionShimmer`
- `promptBorderShimmer`
- `inactiveShimmer`
- `fastModeShimmer`

Subagent pattern:

- `<color>_FOR_SUBAGENTS_ONLY` for colors:
  - `red`
  - `blue`
  - `green`
  - `yellow`
  - `purple`
  - `orange`
  - `pink`
  - `cyan`

Rainbow pattern:

- `rainbow_<color>` and `rainbow_<color>_shimmer` for colors:
  - `red`
  - `orange`
  - `yellow`
  - `green`
  - `blue`
  - `indigo`
  - `violet`

Consider whether to allow these observed-but-not-in-reference tokens only as warnings or with a separate compatibility allowlist:

- `claudeBlue_FOR_SYSTEM_SPINNER`
- `claudeBlueShimmer_FOR_SYSTEM_SPINNER`

Recommendation: allow them with a comment that they are observed in generated/older themes but not in the published token table, or warn in strict mode.

### 3. Clean or consciously quarantine undocumented tokens

After validator exists, decide what to do with current warnings:

Likely remove from Claude theme overrides:

- `background`
- `clawd_background`
- `clawd_body`
- `chromeYellow`
- `professionalBlue`
- `diffAddedWordDimmed`
- `diffRemovedWordDimmed`

Reason: docs say unknown tokens are ignored, so keeping them suggests false control.

Alternative: keep them only in a separate experimental/commentary file is not possible in JSON, so better to remove from actual Claude theme and mention terminal background must be handled by terminal emulator profile.

### 4. Add README validation section

Update:

- `/Users/noomz/Projects/Opensources/noomz-themes/README.md`

Add a short section:

- `scripts/validate-claude-theme.py themes/claude/modus-operandi.json`
- Validate installed active copy:
  - `scripts/validate-claude-theme.py ~/.claude/themes/modus-operandi.json`
- Validate all known active copies:
  - repo copy
  - `~/.claude/themes/modus-operandi.json`
  - `~/.ccs/instances/work/themes/modus-operandi.json`
  - `~/.ccs/instances/personal/themes/modus-operandi.json`

Mention the active preference check:

- `~/.claude/settings.json` should contain `"theme": "custom:modus-operandi"`

Mention CCS if relevant:

- `~/.ccs/config.yaml` should select the intended theme slug for CCS-managed instances if CCS uses that preference.

### 5. Add installer validation hook

Update:

- `/Users/noomz/Projects/Opensources/noomz-themes/scripts/install.sh`

Before copying Claude theme files, run the validator against:

- `themes/claude/modus-operandi.json`

If invalid, abort install.

If warnings only, print them but continue unless a strict env var is set:

- `STRICT=1 scripts/install.sh`

### 6. Add runtime smoke test instructions

Since docs say unknown tokens are ignored, the final proof is runtime visual smoke testing.

Add a manual checklist:

1. Confirm active preference:
   - `~/.claude/settings.json` has `"theme": "custom:modus-operandi"`
2. Temporarily set a known token to an obvious value:
   - `inactive`: `rgb(255, 0, 0)`
3. Save the theme file.
4. Existing Claude Code session should reload automatically.
5. Confirm secondary hints/collapsed text visibly change.
6. Revert the token to the intended value.

Use this for disputed UI areas:

- collapsed hints: `inactive`, `subtle`
- picker/autocomplete/selection: `suggestion`
- input shell mode: `bashBorder`
- permission prompts: `permission`
- plan mode: `planMode`
- message panels in fullscreen: `userMessageBackground`, `bashMessageBackgroundColor`, `messageActionsBackground`

### 7. Separate terminal-emulator contract

Create a small note in README or docs:

Claude Code theme does not control terminal application canvas/background. For glare from the full terminal background, adjust terminal profile colors in the terminal emulator or use an ANSI-based base:

- `light-ansi`
- terminal ANSI palette
- terminal background color

If using cmux/terminal wrapper, identify the actual host terminal profile before changing colors. Do not kill production cmux processes.

## Files likely to change

- `/Users/noomz/Projects/Opensources/noomz-themes/scripts/validate-claude-theme.py`
- `/Users/noomz/Projects/Opensources/noomz-themes/README.md`
- `/Users/noomz/Projects/Opensources/noomz-themes/scripts/install.sh`
- `/Users/noomz/Projects/Opensources/noomz-themes/themes/claude/modus-operandi.json`
- Possibly installed active copies after cleanup:
  - `/Users/noomz/.claude/themes/modus-operandi.json`
  - `/Users/noomz/.ccs/instances/work/themes/modus-operandi.json`
  - `/Users/noomz/.ccs/instances/personal/themes/modus-operandi.json`

## Tests / validation

Run validator against repo file:

```bash
cd /Users/noomz/Projects/Opensources/noomz-themes
python3 scripts/validate-claude-theme.py themes/claude/modus-operandi.json
```

Run validator against installed files:

```bash
python3 scripts/validate-claude-theme.py \
  /Users/noomz/.claude/themes/modus-operandi.json \
  /Users/noomz/.ccs/instances/work/themes/modus-operandi.json \
  /Users/noomz/.ccs/instances/personal/themes/modus-operandi.json \
  /Users/noomz/Projects/Opensources/noomz-themes/themes/claude/modus-operandi.json
```

Check active Claude preference:

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path('/Users/noomz/.claude/settings.json')
print(json.loads(p.read_text()).get('theme'))
PY
```

Expected:

```text
custom:modus-operandi
```

Check base:

```bash
python3 - <<'PY'
import json, pathlib
for path in [
  '/Users/noomz/.claude/themes/modus-operandi.json',
  '/Users/noomz/.ccs/instances/work/themes/modus-operandi.json',
  '/Users/noomz/.ccs/instances/personal/themes/modus-operandi.json',
  '/Users/noomz/Projects/Opensources/noomz-themes/themes/claude/modus-operandi.json',
]:
  data = json.loads(pathlib.Path(path).read_text())
  print(path, data.get('base'))
PY
```

Expected:

```text
light-daltonized
```

## Risks / tradeoffs

- The docs token list may omit internal tokens that still work. Treat undocumented tokens as warnings first, not immediate failures.
- The terminal canvas/background may remain hard to look at because Claude Code explicitly does not control terminal app color scheme.
- CCS may copy or manage theme files differently than stock Claude Code. Keep validating both `~/.claude/themes/` and CCS instance copies.
- Do not mutate `~/.claude/settings.json` or `~/.ccs/config.yaml` blindly beyond explicit theme preference checks.
- Do not kill cmux or Claude/CCS processes to force reload. Prefer file-watch reload or user-driven restart.

## Open questions

1. Should undocumented but observed tokens like `claudeBlue_FOR_SYSTEM_SPINNER` be allowed by default or warned?
2. Should the repo remove ignored tokens immediately, or keep them until runtime testing confirms no effect?
3. Should we add terminal emulator profiles for iTerm2/Ghostty/Apple Terminal to handle the actual background glare?
4. Should the installer update `~/.claude/settings.json` to `custom:modus-operandi`, or only install the theme and print instructions?
