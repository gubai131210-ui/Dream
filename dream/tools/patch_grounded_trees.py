#!/usr/bin/env python3
"""Patch inland assemblers to prefer grounded trees without water-island bases."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = [
    ROOT / "scripts/areas/farm_residential_assembler.gd",
    ROOT / "scripts/areas/farmland_assembler.gd",
    ROOT / "scripts/areas/village_residential_assembler.gd",
]

PAT = re.compile(
    r'^(\t+)var path := "res://assets/sprites/trees/tree_%02d\.png" % \(([^)]+)\)\s*$',
    re.M,
)


def repl(m: re.Match[str]) -> str:
    indent, expr = m.group(1), m.group(2)
    return (
        f'{indent}var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % ({expr})\n'
        f"{indent}if not ResourceLoader.exists(path):\n"
        f'{indent}\tpath = "res://assets/sprites/trees/tree_%02d.png" % ({expr})'
    )


def main() -> None:
    for path in FILES:
        text = path.read_text(encoding="utf-8")
        new, n = PAT.subn(repl, text)
        path.write_text(new, encoding="utf-8")
        print(f"{path.name}: {n} tree path(s) patched")


if __name__ == "__main__":
    main()
