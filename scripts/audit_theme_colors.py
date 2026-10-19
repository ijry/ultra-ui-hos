#!/usr/bin/env python3
"""Catalogue the hardcoded colours still left in the components after the theme pass.

This is an informational audit, not a gate: it splits the remaining literals into
buckets so the design team knows exactly what still needs a dark-mode value, and so a
future contributor can tell "already mode-aware" from "needs a decision" at a glance.
"""
from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ETS = ROOT / "ultra-ui/src/main/ets"
TOKENS_FILE = ETS / "internal/UPThemeTokens.ets"

COLOUR = re.compile(r"'(#[0-9a-fA-F]{3,8}|rgba?\([^']*\))'")


def token_light_values() -> dict[str, str]:
    text = TOKENS_FILE.read_text(encoding="utf-8")
    block = re.search(r"LIGHT: Map<string, string> = new Map<string, string>\(\[(.*?)\n  \]\);",
                      text, re.S)
    assert block is not None, "LIGHT table not found"
    values: dict[str, str] = {}
    for token, value in re.findall(r"\['([a-z0-9-]+)', '([^']+)'\]", block.group(1)):
        values.setdefault(value.lower(), token)
    return values


def main() -> None:
    light_by_value = token_light_values()
    already_adaptive = 0
    already_neutral = 0
    parse_fallback = 0
    maps_to_token: dict[str, list[str]] = defaultdict(list)
    no_token: dict[str, int] = defaultdict(int)
    transparent = 0

    for directory in ("components", "internal"):
        for path in sorted((ETS / directory).glob("*.ets")):
            if path.name == "UPThemeTokens.ets":
                continue
            for line in path.read_text(encoding="utf-8").split("\n"):
                if "UPColor.adaptive(" in line:
                    already_adaptive += line.count("UPColor.adaptive(")
                if "UPColor.neutral(" in line:
                    already_neutral += line.count("UPColor.neutral(")
                for match in COLOUR.finditer(line):
                    value = match.group(1).lower()
                    context = line[max(0, match.start() - 24):match.start()]
                    if "adaptive(" in context or "neutral(" in context:
                        continue
                    if value in ("#00000000", "transparent"):
                        transparent += 1
                        continue
                    if "UPColor.parse(" in line:
                        parse_fallback += 1
                    token = light_by_value.get(value)
                    if token is not None:
                        maps_to_token[f"{value} -> {token}"].append(path.stem)
                    else:
                        no_token[value] += 1

    print("theme colour audit")
    print(f"  already mode-aware: adaptive()={already_adaptive}, neutral()={already_neutral}")
    print(f"  parse() fallbacks (theme-aware for named colours): {parse_fallback}")
    print(f"  transparent placeholders (no dark value needed): {transparent}")
    print()
    if maps_to_token:
        print(f"  still-literal values that MATCH a known token ({len(maps_to_token)}):")
        for key in sorted(maps_to_token):
            files = sorted(set(maps_to_token[key]))
            print(f"    {key}  ({len(files)} files: {', '.join(files[:6])}{'…' if len(files) > 6 else ''})")
        print()
    top = sorted(no_token.items(), key=lambda item: -item[1])[:20]
    print(f"  component-specific literals WITHOUT an upstream token "
          f"({len(no_token)} distinct, need design input for dark mode):")
    for value, count in top:
        print(f"    {value}: {count}")
    remaining = sum(no_token.values())
    print()
    print(f"summary: {already_adaptive + already_neutral} sites mode-aware, "
          f"{sum(len(v) for v in maps_to_token.values())} literals map to a token but stay literal, "
          f"{remaining} literals await a dark-mode decision")


if __name__ == "__main__":
    main()
