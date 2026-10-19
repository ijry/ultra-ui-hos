#!/usr/bin/env python3
"""Regression contracts for ArkUI component-struct compiler hazards."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMP = ROOT / "ultra-ui/src/main/ets/components"

COMPONENTS = (
    "UPAvatar", "UPAvatarGroup", "UPInput", "UPTextarea", "UPSwitch", "UPRate", "UPNumberBox",
    "UPCircleProgress", "UPAlert", "UPNotify", "UPNoticeBar", "UPActionSheet", "UPBackTop",
    "UPCollapse", "UPCollapseItem", "UPDropdown", "UPDropdownItem",
)

# Custom components inherit CommonAttribute methods. A private helper with one of
# these names is compiled as an incompatible override instead of a normal helper.
FORBIDDEN_HELPER_NAMES = {
    "UPAvatar": ("background",),
    "UPInput": ("background", "borderWidth"),
}

# The same collision applies to every component struct, so these names are banned
# repository-wide instead of per component.
GLOBAL_FORBIDDEN_HELPER_NAMES = (
    "width", "height", "background", "backgroundColor", "borderWidth", "borderRadius",
    "borderColor", "padding", "margin", "opacity", "position", "clip", "visibility",
    "zIndex", "enabled", "align", "direction", "constraintSize", "offset", "overlay",
)


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path}"
    return path.read_text(encoding="utf-8")


def decorated_builder_first_statement(source: str) -> str | None:
    lines = source.splitlines()
    for index, line in enumerate(lines):
        if "@Builder" not in line:
            continue
        opening = index + 1
        while opening < len(lines) and "{" not in lines[opening]:
            opening += 1
        if opening >= len(lines):
            continue
        statement = opening + 1
        while statement < len(lines) and not lines[statement].strip():
            statement += 1
        if statement < len(lines):
            return lines[statement].strip()
    return None


def build_first_statement(source: str) -> str | None:
    match = re.search(r"\n\s*build\s*\(\)\s*\{", source)
    if match is None:
      return None
    lines = source[match.end():].splitlines()
    for line in lines:
        stripped = line.strip()
        if stripped:
            return stripped
    return None


def main() -> None:
    for component in COMPONENTS:
        source = read(COMP / f"{component}.ets")
        for helper in FORBIDDEN_HELPER_NAMES.get(component, ()):
            assert not re.search(rf"\bprivate\s+{re.escape(helper)}\s*\(", source), (
                f"{component} must not define helper {helper}(), which collides with CommonAttribute"
            )

        first_statement = decorated_builder_first_statement(source)
        assert first_statement is None or not re.match(r"(?:const|let)\b", first_statement), (
            f"{component} @Builder must start with UI syntax, found {first_statement!r}"
        )

        build_statement = build_first_statement(source)
        assert build_statement is None or not re.match(r"(?:const|let)\b", build_statement), (
            f"{component} build() must start with UI syntax, found {build_statement!r}"
        )

    for path in sorted(COMP.glob("*.ets")):
        source = read(path)
        for helper in GLOBAL_FORBIDDEN_HELPER_NAMES:
            assert not re.search(rf"\bprivate\s+{re.escape(helper)}\s*\(", source), (
                f"{path.name} must not define helper {helper}(), which collides with CommonAttribute"
            )

    avatar_group = read(COMP / "UPAvatarGroup.ets")
    assert "this.more()" not in avatar_group, (
        "UPAvatarGroup must render its optional overflow node inside the single Row root"
    )

    textarea = read(COMP / "UPTextarea.ets")
    assert ": object" not in textarea, "UPTextarea helpers must use explicit ArkTS value types"

    switch_demo = read(ROOT / "sample/entry/src/main/ets/demos/SwitchDemo.ets")
    assert not re.search(r"@State\s+private\s+enabled\s*:", switch_demo), (
        "SwitchDemo must not shadow the CommonAttribute enabled() modifier"
    )

    print("arkts component contract: PASS")


if __name__ == "__main__":
    main()
