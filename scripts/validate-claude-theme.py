#!/usr/bin/env python3
"""Validate Claude Code custom theme JSON files.

This is intentionally small and dependency-free so install.sh can run it before
copying themes into active Claude/CCS locations.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ALLOWED_TOP_LEVEL_KEYS = {"name", "base", "overrides"}
LEGACY_TOP_LEVEL_KEYS = {"colors", "id"}
ALLOWED_BASES = {
    "dark",
    "light",
    "dark-daltonized",
    "light-daltonized",
    "dark-ansi",
    "light-ansi",
}

DOCUMENTED_TOKENS = {
    # Text and accent
    "claude",
    "text",
    "inverseText",
    "inactive",
    "subtle",
    "suggestion",
    "permission",
    "remember",
    # Status
    "success",
    "error",
    "warning",
    "merged",
    # Input box and mode indicators
    "promptBorder",
    "planMode",
    "autoAccept",
    "bashBorder",
    "ide",
    "fastMode",
    # Diff
    "diffAdded",
    "diffRemoved",
    "diffAddedDimmed",
    "diffRemovedDimmed",
    "diffAddedWord",
    "diffRemovedWord",
    # Fullscreen mode
    "userMessageBackground",
    "userMessageBackgroundHover",
    "messageActionsBackground",
    "bashMessageBackgroundColor",
    "memoryBackgroundColor",
    "selectionBg",
    # Usage meter and labels
    "rate_limit_fill",
    "rate_limit_empty",
    "briefLabelYou",
    "briefLabelClaude",
    # Documented shimmer variants
    "claudeShimmer",
    "warningShimmer",
    "permissionShimmer",
    "promptBorderShimmer",
    "inactiveShimmer",
    "fastModeShimmer",
}

SUBAGENT_COLORS = {"red", "blue", "green", "yellow", "purple", "orange", "pink", "cyan"}
RAINBOW_COLORS = {"red", "orange", "yellow", "green", "blue", "indigo", "violet"}

# Observed in generated/older themes, but not in the published token table.
COMPATIBILITY_TOKENS = {
    "claudeBlue_FOR_SYSTEM_SPINNER",
    "claudeBlueShimmer_FOR_SYSTEM_SPINNER",
}

ANSI_NAMES = {
    "black",
    "red",
    "green",
    "yellow",
    "blue",
    "magenta",
    "cyan",
    "white",
    "brightBlack",
    "brightRed",
    "brightGreen",
    "brightYellow",
    "brightBlue",
    "brightMagenta",
    "brightCyan",
    "brightWhite",
    "gray",
    "grey",
}

HEX_RE = re.compile(r"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")
RGB_RE = re.compile(r"^rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)$")
ANSI256_RE = re.compile(r"^ansi256\(\s*([0-9]{1,3})\s*\)$")
ANSI_RE = re.compile(r"^ansi:([A-Za-z]+)$")


def is_known_token(token: str) -> bool:
    if token in DOCUMENTED_TOKENS or token in COMPATIBILITY_TOKENS:
        return True
    if token.endswith("_FOR_SUBAGENTS_ONLY"):
        return token.removesuffix("_FOR_SUBAGENTS_ONLY") in SUBAGENT_COLORS
    if token.startswith("rainbow_"):
        rest = token.removeprefix("rainbow_")
        if rest.endswith("_shimmer"):
            rest = rest.removesuffix("_shimmer")
        return rest in RAINBOW_COLORS
    return False


def is_valid_color(value: str) -> bool:
    if HEX_RE.match(value):
        return True
    rgb_match = RGB_RE.match(value)
    if rgb_match:
        return all(0 <= int(component) <= 255 for component in rgb_match.groups())
    ansi256_match = ANSI256_RE.match(value)
    if ansi256_match:
        return 0 <= int(ansi256_match.group(1)) <= 255
    ansi_match = ANSI_RE.match(value)
    if ansi_match:
        return ansi_match.group(1) in ANSI_NAMES
    return False


def validate_theme(path: Path, *, strict_tokens: bool) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []

    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as exc:
        return [f"cannot read: {exc}"], warnings

    try:
        data: Any = json.loads(raw)
    except json.JSONDecodeError as exc:
        return [f"invalid JSON: {exc}"], warnings

    if not isinstance(data, dict):
        return ["theme must be a JSON object"], warnings

    top_level_keys = set(data)
    for key in sorted(top_level_keys - ALLOWED_TOP_LEVEL_KEYS):
        if key in LEGACY_TOP_LEVEL_KEYS:
            errors.append(f"legacy/confusing top-level key {key!r}; use 'overrides' for colors")
        else:
            errors.append(f"unknown top-level key {key!r}")

    if "name" in data and not isinstance(data["name"], str):
        errors.append("'name' must be a string")

    if "base" in data:
        base = data["base"]
        if not isinstance(base, str):
            errors.append("'base' must be a string")
        elif base not in ALLOWED_BASES:
            errors.append(f"unsupported base {base!r}; expected one of {', '.join(sorted(ALLOWED_BASES))}")

    overrides = data.get("overrides", {})
    if not isinstance(overrides, dict):
        errors.append("'overrides' must be an object")
        return errors, warnings

    for token, value in sorted(overrides.items()):
        if not isinstance(value, str):
            errors.append(f"override {token!r} value must be a string")
            continue
        if not is_valid_color(value):
            errors.append(
                f"override {token!r} has invalid color {value!r}; expected #rgb, #rrggbb, rgb(r,g,b), ansi256(n), or ansi:<name>"
            )
        if not is_known_token(token):
            message = f"unknown override token {token!r}; Claude Code silently ignores unknown tokens"
            if strict_tokens:
                errors.append(message)
            else:
                warnings.append(message)

    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Claude Code custom theme JSON files.")
    parser.add_argument("paths", nargs="+", type=Path, help="theme JSON file(s) to validate")
    parser.add_argument(
        "--strict-tokens",
        action="store_true",
        help="treat unknown override tokens as errors instead of warnings",
    )
    args = parser.parse_args()

    had_errors = False
    for path in args.paths:
        errors, warnings = validate_theme(path, strict_tokens=args.strict_tokens)
        print(f"{path}:")
        if errors:
            had_errors = True
            for error in errors:
                print(f"  ERROR: {error}")
        if warnings:
            for warning in warnings:
                print(f"  WARN: {warning}")
        if not errors and not warnings:
            print("  OK")
        elif not errors:
            print("  OK with warnings")

    return 1 if had_errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
