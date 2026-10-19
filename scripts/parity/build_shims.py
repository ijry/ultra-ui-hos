#!/usr/bin/env python3
"""Copy the pure ArkTS core/internal modules into a temp dir as loadable `.ts` shims.

`node --experimental-strip-types` can execute TypeScript directly, but it needs
`.ts` extensions on relative imports and `import type` on type-only specifiers.
This builder copies the deterministic, side-effect-free modules and rewrites their
imports so the committed parity harnesses can diff them against the upstream JS.
Only modules that are pure computation (no ArkUI decorators) are shimmed.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / "ultra-ui/src/main/ets/core"
INTERNAL = ROOT / "ultra-ui/src/main/ets/internal"

# module file -> source directory
MODULES = {
    "UPTypes.ets": CORE,
    "UPTheme.ets": CORE,
    "UPMath.ets": CORE,
    "UPValidate.ets": CORE,
    "UPFormat.ets": CORE,
    "UPGradient.ets": CORE,
    "UPValidator.ets": CORE,
    "UPI18n.ets": CORE,
    "UPThemeManager.ets": CORE,
    "UPColor.ets": CORE,
    "UPLayers.ets": CORE,
    "UPLocaleCatalog.ets": INTERNAL,
    "UPThemeTokens.ets": INTERNAL,
}

# specifiers that are type-only and therefore need `import type`
TYPE_ONLY = {"UPRawValue", "UPStyleInput", "UPStyleObject", "UPThemeValues",
             "UPCompatibilityListener", "UPBuilder", "UPEdgeInput"}


def rewrite_import(line: str) -> str:
    match = re.match(r"import \{([^}]*)\} from '([^']+)';", line)
    if match is None:
        return line
    names = [name.strip() for name in match.group(1).split(",") if name.strip()]
    source = match.group(2)
    # flatten ../internal/X and ./X onto the same temp directory
    module = source.split("/")[-1]
    target = f"./{module}.ts"
    type_names = [n for n in names if n in TYPE_ONLY]
    value_names = [n for n in names if n not in TYPE_ONLY]
    lines: list[str] = []
    if value_names:
        lines.append("import { " + ", ".join(value_names) + f" }} from '{target}';".replace("}}", "}"))
    if type_names:
        lines.append("import type { " + ", ".join(type_names) + f" }} from '{target}';".replace("}}", "}"))
    return "\n".join(lines)


def build(dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    for filename, directory in MODULES.items():
        source = (directory / filename).read_text(encoding="utf-8")
        out_lines: list[str] = []
        for line in source.split("\n"):
            if line.startswith("import {"):
                out_lines.append(rewrite_import(line))
            else:
                out_lines.append(line)
        (dest / f"{filename[:-4]}.ts").write_text("\n".join(out_lines), encoding="utf-8")


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / ".parity-shims"
    build(target)
    print(f"built {len(MODULES)} shims into {target}")
