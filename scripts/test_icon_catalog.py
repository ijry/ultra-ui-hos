#!/usr/bin/env python3
"""Contract checks for the pinned uview-plus icon font and generated catalog."""
from __future__ import annotations

import hashlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAWFILE = ROOT / "ultra-ui/src/main/resources/rawfile/upicon.ttf"
GLYPHS = ROOT / "ultra-ui/src/main/ets/internal/UPIconGlyphs.ets"
GENERATOR = ROOT / "tools/generate_upicon_catalog.py"
UPSTREAM = ROOT / "tools/upstream/uview-plus-icons.js"
ICON = (ROOT / "ultra-ui/src/main/ets/components/UPIcon.ets").read_text(encoding="utf-8")

EXPECTED_SHA256 = "4bc8cc97559c0a52ea4f5ce0563e1bf3a7f89d660f74792e662e76d49eae4707"
ENTRY = re.compile(
    r"(?P<quote>['\"])(?P<name>[^'\"]+)(?P=quote)\s*:\s*"
    r"(?P<glyph_quote>['\"])\\u(?P<glyph>[0-9a-fA-F]{4})(?P=glyph_quote)"
)


def parse_upstream(source: str) -> dict[str, int]:
    entries = {
        match.group("name").removeprefix("uicon-"): int(match.group("glyph"), 16)
        for match in ENTRY.finditer(source)
    }
    return entries


GENERATED_ENTRY = re.compile(
    r"\[\s*(?P<quote>['\"])(?P<name>[^'\"]+)(?P=quote)\s*,\s*"
    r"(?P<glyph_quote>['\"])\\u(?P<glyph>[0-9a-fA-F]{4})(?P=glyph_quote)\s*\]"
)


def parse_generated(source: str) -> dict[str, int]:
    return {
        match.group("name"): int(match.group("glyph"), 16)
        for match in GENERATED_ENTRY.finditer(source)
    }


def main() -> None:
    assert RAWFILE.is_file(), f"missing bundled icon font: {RAWFILE}"
    assert hashlib.sha256(RAWFILE.read_bytes()).hexdigest() == EXPECTED_SHA256
    assert RAWFILE.read_bytes()[:4] in (b"\x00\x01\x00\x00", b"OTTO")

    assert GENERATOR.is_file(), f"missing icon catalog generator: {GENERATOR}"
    assert UPSTREAM.is_file(), f"missing pinned icon source snapshot: {UPSTREAM}"
    assert GLYPHS.is_file(), f"missing generated icon catalog: {GLYPHS}"

    upstream = parse_upstream(UPSTREAM.read_text(encoding="utf-8"))
    generated = parse_generated(GLYPHS.read_text(encoding="utf-8"))
    assert len(upstream) == 213, f"unexpected upstream icon count: {len(upstream)}"
    assert generated == upstream, "generated ArkTS glyph catalog differs from pinned source"
    assert generated["search"] == 0xE62A
    assert generated["IE-circle-fill"] == 0xE889

    assert "UPIconGlyphs" in ICON
    assert "codePoint" in ICON
    assert "fontFamily" in ICON
    assert "registerFont" in ICON
    assert "$rawfile" in ICON
    assert "unknown" in ICON.lower() or "empty" in ICON.lower()

    print("icon catalog contract: PASS")


if __name__ == "__main__":
    main()
