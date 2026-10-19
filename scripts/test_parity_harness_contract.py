#!/usr/bin/env python3
"""Contract for the committed offline parity harness (scripts/parity/*).

The harness diffs the ArkTS core modules against the upstream uview-plus JS. This
contract does not run node; it guards that the harness stays present, self-contained,
covers every pure module, and stays in sync with the real source's import surface.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARITY = ROOT / "scripts/parity"
BUILDER = PARITY / "build_shims.py"
HARNESS = PARITY / "parity.mjs"
RUNNER = PARITY / "run.sh"
CORE = ROOT / "ultra-ui/src/main/ets/core"


def read(path: Path) -> str:
    assert path.is_file(), f"missing file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def main() -> None:
    builder = read(BUILDER)
    harness = read(HARNESS)
    runner = read(RUNNER)

    # every pure core module must be shimmed so the harness can import it
    for module in ("UPMath.ets", "UPValidate.ets", "UPFormat.ets", "UPGradient.ets",
                   "UPValidator.ets", "UPI18n.ets", "UPThemeManager.ets", "UPColor.ets",
                   "UPLocaleCatalog.ets", "UPThemeTokens.ets"):
        assert f'"{module}"' in builder, f"parity builder does not shim {module}"

    # the builder must know which specifiers are type-only, or strip-types will choke
    assert "TYPE_ONLY" in builder and "import type" in builder, (
        "parity builder must emit `import type` for type-only specifiers"
    )
    # keep TYPE_ONLY aligned with what the real modules import type-only
    for name in ("UPRawValue", "UPThemeValues", "UPStyleInput"):
        assert name in builder, f"parity builder TYPE_ONLY set is missing {name}"

    # the harness must diff each subsystem against its upstream source of truth
    for probe in ("libs/function/digit.js", "libs/function/test.js", "libs/function/index.js",
                  "libs/function/colorGradient.js", "libs/i18n/locale-packs.js", "libs/theme/theme.js",
                  "libs/util/async-validator.js"):
        assert probe in harness, f"parity harness does not compare against {probe}"
    assert harness.count("fail(") >= 8, "parity harness must record per-subsystem failures"
    assert "process.exit(failures === 0 ? 0 : 1)" in harness, (
        "parity harness must exit non-zero on any mismatch"
    )

    # the runner must skip cleanly rather than fail when the toolchain is absent
    for skip in ("node not found", "upstream checkout not found", "node >= 22 required"):
        assert skip in runner, f"parity runner must skip gracefully: {skip}"
    assert "TZ=UTC" in runner, "parity runner must pin UTC for the date-format comparison"
    assert "--experimental-strip-types" in runner, "parity runner must run TypeScript directly"

    # the shim builder stays honest: the modules it lists must actually exist
    for match in re.finditer(r'"(UP\w+\.ets)": (CORE|INTERNAL)', builder):
        name = match.group(1)
        directory = "core" if match.group(2) == "CORE" else "internal"
        candidate = ROOT / "ultra-ui/src/main/ets" / directory / name
        assert candidate.is_file(), f"parity builder references a missing module: {name}"

    print("parity harness contract: PASS")


if __name__ == "__main__":
    main()
