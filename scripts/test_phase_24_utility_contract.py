#!/usr/bin/env python3
"""Static contracts for the Phase 24 shared-utility pass."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "ultra-ui/src/main/ets/core"
DEMO = ROOT / "sample/entry/src/main/ets/demos/UtilsDemo.ets"
CATALOG = ROOT / "sample/entry/src/main/ets/catalog/SampleCatalog.ets"
PAGE = ROOT / "sample/entry/src/main/ets/pages/SamplePage.ets"
INDEX = ROOT / "ultra-ui/Index.ets"
README = ROOT / "README.md"
NOTE = ROOT / "docs/compatibility/phase-24.md"

FORBIDDEN = (
    "WebView", "webview", "FastView", ".xyfv", "@kit.NetworkKit", "http://",
    "https://", "JSON.parse", "fetch(", "axios", "setClipboardData",
    "openSystemSettings", "plus.runtime.quit", "navigateTo", "RichText",
)

# ArkTS module -> exported symbols the phase must provide
MODULES = {
    "UPValidate.ets": (
        "upIsEmail", "upIsMobile", "upIsUrl", "upIsDate", "upIsCalendarDate", "upIsDateISO",
        "upIsNumeric", "upIsDigits", "upIsIdCard", "upIsCarNo", "upIsAmount", "upIsChinese",
        "upIsLetter", "upIsEnOrNum", "upIsLandline", "upIsCode", "upIsImage", "upIsVideo",
        "upIsEmpty", "upIsEmptyList", "upIsLeapYear", "upDaysInMonth", "upDateParts",
        "upContains", "upInRange", "upInRangeLength",
    ),
    "UPMath.ets": ("UPMath",),
    "UPFormat.ets": ("UPFormat", "UPTimeParts", "UPQueryEntry", "UPQueryArrayFormat"),
    "UPGradient.ets": ("UPGradient", "UPRgbColor", "UPHslColor"),
    "UPLayers.ets": ("UPZIndex", "UPLegacyColor", "UP_THEME_TYPES", "UP_UPSTREAM_CONFIG_VERSION"),
}

# class -> static members the callers rely on
STATIC_MEMBERS = {
    "UPMath.ets": ("strip", "digitLength", "float2Fixed", "checkBoundary", "enableBoundaryChecking",
                   "lastOverflow", "times", "plus", "minus", "divide", "round", "plusAll",
                   "minusAll", "timesAll", "divideAll", "clamp"),
    "UPFormat.ets": ("padZero", "timeFormat", "timeFrom", "priceFormat", "durationText",
                     "durationValue", "trim", "queryParams", "typeIcon", "partsOf",
                     "timestampOf", "toMilliseconds"),
    "UPGradient.ets": ("expandHex", "toRgb", "toRgbText", "toHex", "toRgba", "gradient",
                       "toHsl", "fromHsl", "lightColor"),
}

# upstream constants that must be mirrored verbatim
CONSTANTS = {
    "UPLayers.ets": ("10090", "10080", "10075", "10070", "980", "975", "970", "965",
                     "#3c9cff", "#f9ae3d", "#f56c6c", "#5ac725", "#e4e7ed"),
    "UPFormat.ets": ("86400", "3600", "2592000"),
}


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def code_only(source: str) -> str:
    """Drops comment lines so clock references in JSDoc do not trip the purity check."""
    kept: list[str] = []
    for line in source.split("\n"):
        stripped = line.strip()
        if stripped.startswith("*") or stripped.startswith("/*") or stripped.startswith("//"):
            continue
        kept.append(line)
    return "\n".join(kept)


def main() -> None:
    sources: dict[str, str] = {}
    exported = 0
    for filename, symbols in MODULES.items():
        source = read(CORE / filename)
        sources[filename] = source
        for symbol in symbols:
            exported += 1
            assert re.search(rf"export (?:function|class|interface|type|const) {symbol}\b", source), (
                f"{filename} must export {symbol}"
            )
        for token in FORBIDDEN:
            assert token not in source, f"{filename} contains forbidden boundary {token}"
        # ArkTS restrictions: no index signatures, no any/unknown, no async plumbing
        for banned in ("Record<", ": any", ": unknown", "async ", "await ", "Promise<"):
            assert banned not in source, f"{filename} must not use {banned.strip()}"

    for filename, members in STATIC_MEMBERS.items():
        source = sources[filename]
        for member in members:
            assert re.search(rf"static (?:readonly )?{member}\b", source), (
                f"{filename} is missing the static member {member}"
            )

    for filename, tokens in CONSTANTS.items():
        source = sources[filename]
        for token in tokens:
            assert token in source, f"{filename} must mirror the upstream constant {token}"

    # UPMath keeps the upstream scale-to-integer strategy rather than naive float math
    math_source = sources["UPMath.ets"]
    assert "float2Fixed(left)" in math_source and "Math.pow(10, scale)" in math_source, (
        "UPMath.times must scale both operands to integers"
    )
    assert "MAX_SAFE_INTEGER" in math_source and "MIN_SAFE_INTEGER" in math_source, (
        "UPMath must keep the upstream boundary check"
    )

    # UPFormat stays pure: the caller supplies `now`
    format_source = sources["UPFormat.ets"]
    assert "timeFrom(timestamp: number, now: number" in format_source, (
        "UPFormat.timeFrom must take `now` from the caller"
    )
    assert "daysFromCivil" in format_source and "civilFromDays" in format_source, (
        "UPFormat must convert dates without the platform parser"
    )
    format_code = code_only(format_source)
    assert "Date.now" not in format_code and "new Date" not in format_code, (
        "UPFormat must not read the platform clock"
    )

    # the two date semantics are documented and separated
    validate_source = sources["UPValidate.ets"]
    assert "upIsCalendarDate" in validate_source and "upDaysInMonth(parts[0], parts[1])" in validate_source, (
        "UPValidate must offer the stricter calendar check"
    )

    index = read(INDEX)
    for filename, symbols in MODULES.items():
        for symbol in symbols:
            assert symbol in index, f"public entry missing {symbol}"

    demo = read(DEMO)
    assert "@lingyun/ultra-ui-hos" in demo, "UtilsDemo must import from the public HAR entry"
    assert not re.search(r"=>\s*this\.", demo), "UtilsDemo must use explicit void block bodies"
    for token in ("UPMath.plus", "UPMath.round", "UPFormat.timeFormat", "UPFormat.priceFormat",
                  "UPFormat.queryParams", "UPGradient.gradient", "UPGradient.lightColor",
                  "UPZIndex.TOAST", "UPLegacyColor.PRIMARY", "upIsMobile", "upIsCalendarDate"):
        assert token in demo, f"UtilsDemo does not demonstrate {token}"

    catalog = read(CATALOG)
    page = read(PAGE)
    assert "'utils'" in catalog, "sample catalog must register the utils route"
    assert "Components Y" in catalog, "sample catalog must open the Components Y group"
    assert "UtilsDemo()" in page and "case 'utils'" in page, "SamplePage must route the utils demo"

    readme = read(README)
    note = read(NOTE)
    for phrase in ("阶段 24", "phase-24.md"):
        assert phrase in readme or phrase in note, f"Phase 24 documentation missing {phrase}"
    for phrase in (
        "API 24", "5.0.0(12)", "UPMath", "UPFormat", "UPValidate", "UPGradient", "UPZIndex",
        "priceFormat", "timeFrom", "no-op", "设备验证", "skipped",
    ):
        assert phrase in note, f"phase-24 note missing {phrase}"

    print(f"phase 24 utility contract: PASS ({exported} exports, {len(MODULES)} modules)")


if __name__ == "__main__":
    main()
