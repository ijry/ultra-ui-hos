#!/usr/bin/env python3
"""Every upstream component prop must exist on the matching ArkTS Props class."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = Path('/Users/admin/Documents/Repos/xyito/open/uview-plus/src/uni_modules/uview-plus/components')
COMPONENTS = ROOT / "ultra-ui/src/main/ets/components"

# Upstream directories that map onto a differently named or split ArkTS component.
ALIASES = {
    "u-datetime-picker": ["UPDatePicker", "UPTimePicker"],
    "u-dragsort": ["UPDragSort"],
    "u-float-button": ["UPFloatingBubble"],
    "u-table2": ["UPTable2"],
    "u-toast": ["UPToastHost"],
    "u-tree": ["UPTreeSelect"],
}

# Upstream helper directories folded into another component's data model.
SKIPPED = ("u-action-sheet-data", "u-picker-data")


def camel(name: str) -> str:
    parts = name.replace("u-", "", 1).split("-")
    return "UP" + "".join(part[:1].upper() + part[1:] for part in parts)


def brace_block(text: str, marker: str) -> str | None:
    """Return the brace-balanced body that follows marker."""
    start = text.find(marker)
    if start == -1:
        return None
    brace = text.find("{", start + len(marker) - 1)
    if brace == -1:
        return None
    depth = 0
    for index in range(brace, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[brace + 1:index]
    return None


def top_level_keys(block: str) -> set[str]:
    """Keys declared at nesting depth zero of a JS object literal body."""
    depth = 0
    flattened = ""
    for char in block:
        if char in "{[(":
            depth += 1
        elif char in "}])":
            depth -= 1
        if depth == 0:
            flattened += char
    return {match.group(1) for match in re.finditer(r"(?:^|,)\s*([A-Za-z_][A-Za-z0-9_]*)\s*:", flattened)}


def upstream_props(directory: Path) -> set[str]:
    names: set[str] = set()
    primary = directory / f"{directory.name}.vue"
    for candidate in (directory / "props.js", primary):
        if not candidate.is_file():
            continue
        text = candidate.read_text(encoding="utf-8")
        for marker in ("props: {", "props:{"):
            block = brace_block(text, marker)
            if block is not None:
                names |= top_level_keys(block)
    return names


def implemented_fields(names: list[str]) -> set[str]:
    fields: set[str] = set()
    for name in names:
        path = COMPONENTS / f"{name}.ets"
        assert path.is_file(), f"missing component: {name}.ets"
        text = path.read_text(encoding="utf-8")
        for pattern in (rf"export class {name}Props \{{(.*?)\n\}}",
                        rf"export interface {name}Options \{{(.*?)\n\}}"):
            match = re.search(pattern, text, re.S)
            if match is None:
                continue
            for field in re.finditer(r"(?:^|[;{]|\s)([A-Za-z_][A-Za-z0-9_]*)\??\s*[:=]", match.group(1), re.M):
                fields.add(field.group(1))
    return fields


def main() -> None:
    assert UPSTREAM.is_dir(), f"upstream checkout is required at {UPSTREAM}"
    gaps: list[str] = []
    checked = 0
    for directory in sorted(UPSTREAM.iterdir()):
        if not directory.is_dir() or not directory.name.startswith("u-") or directory.name in SKIPPED:
            continue
        targets = ALIASES.get(directory.name, [camel(directory.name)])
        have = implemented_fields(targets)
        missing = sorted(prop for prop in upstream_props(directory) if prop not in have)
        checked += 1
        if missing:
            gaps.append(f"{directory.name} -> {'+'.join(targets)}: {', '.join(missing)}")
    assert checked >= 138, f"expected at least 138 upstream UI directories, scanned {checked}"
    assert not gaps, "upstream props without a matching field:\n  " + "\n  ".join(gaps)
    print(f"upstream prop coverage: PASS ({checked} directories)")


if __name__ == "__main__":
    main()
