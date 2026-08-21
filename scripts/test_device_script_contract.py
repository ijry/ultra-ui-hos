#!/usr/bin/env python3
"""Regression contract for treating hdc's [Empty] response as no device."""
from __future__ import annotations

import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/capture-screenshots.sh"
TOOLCHAIN = ROOT / "scripts/verify-toolchain.sh"


def main() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        fake_hdc = Path(tmp) / "hdc"
        fake_hdc.write_text(
            "#!/usr/bin/env bash\n"
            "if [[ \"$1\" == \"list\" ]]; then echo '[Empty]'; fi\n"
            "exit 0\n",
            encoding="utf-8",
        )
        fake_hdc.chmod(0o755)
        result = subprocess.run(
            ["bash", str(SCRIPT), str(Path(tmp) / "screenshots")],
            env={**os.environ, "HDC_BIN": str(fake_hdc)},
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        assert "screenshots: skipped" in result.stdout, result.stdout
        assert "screenshots: captured" not in result.stdout, result.stdout

    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        fake_hdc = root / "hdc"
        fake_hdc.write_text(
            "#!/usr/bin/env bash\n"
            "if [[ \"$1\" == \"version\" ]]; then echo 'fake hdc'; fi\n"
            "if [[ \"$1\" == \"list\" ]]; then echo '[Empty]'; fi\n"
            "exit 0\n",
            encoding="utf-8",
        )
        fake_hdc.chmod(0o755)
        fake_tool = root / "tool"
        fake_tool.write_text("#!/usr/bin/env bash\necho fake-tool\n", encoding="utf-8")
        fake_tool.chmod(0o755)
        fake_sdk = root / "sdk"
        fake_sdk.mkdir()
        result = subprocess.run(
            ["bash", str(TOOLCHAIN)],
            env={
                **os.environ,
                "NODE_BIN": str(fake_tool),
                "HVIGOR_BIN": str(fake_tool),
                "OHPM_BIN": str(fake_tool),
                "HDC_BIN": str(fake_hdc),
                "SDK_DIR": str(fake_sdk),
                "DEVECO_SDK_HOME": str(root),
            },
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr
        assert "device: skipped" in result.stdout, result.stdout
        assert "device: available" not in result.stdout, result.stdout

    print("device script contract: PASS")


if __name__ == "__main__":
    main()
