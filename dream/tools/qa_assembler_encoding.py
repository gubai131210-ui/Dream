# -*- coding: utf-8 -*-
"""Fail if GDScript string literals still contain UTF-8-as-Latin1 mojibake."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
STR_RE = re.compile(r'"([^"\\]*)"')
MOJI = set("Ãåæçèéä")


def looks_mojibake(s: str) -> bool:
    if not s or any(ord(c) > 255 for c in s):
        return False
    if all(ord(c) < 128 for c in s):
        return False
    return any(c in s for c in MOJI)


def main() -> int:
    bad: list[str] = []
    for path in sorted(SCRIPTS.rglob("*.gd")):
        text = path.read_text(encoding="utf-8")
        for i, line in enumerate(text.splitlines(), 1):
            for m in STR_RE.finditer(line):
                s = m.group(1)
                if looks_mojibake(s):
                    bad.append(f"{path.relative_to(ROOT)}:{i} {s[:40]!r}")
    if bad:
        print("FAIL script encoding mojibake")
        for b in bad[:40]:
            print(" ", b)
        print(f"… total {len(bad)}")
        return 1
    print("GREEN script encoding QA (no latin1-mojibake titles in scripts/)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
