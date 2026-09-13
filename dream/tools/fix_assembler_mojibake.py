# -*- coding: utf-8 -*-
"""Repair UTF-8-as-Latin1 mojibake inside GDScript string literals."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGETS = [
    ROOT / "scripts/areas/farmland_assembler.gd",
    ROOT / "scripts/areas/farm_residential_assembler.gd",
    ROOT / "scripts/areas/village_residential_assembler.gd",
]

# Match double-quoted GDScript strings (no escapes of quotes expected in titles).
STR_RE = re.compile(r'"([^"\\]*)"')


def looks_mojibake(s: str) -> bool:
    if not s or all(ord(c) < 128 for c in s):
        return False
    if any(ord(c) > 255 for c in s):
        return False  # already has real multi-byte unicode beyond latin1
    # Classic UTF-8 Chinese misread as latin-1: lots of Ã/å/æ/ç/è/é
    return any(c in s for c in "Ãåæçèéä¸â")


def repair(s: str) -> str | None:
    try:
        out = bytes(ord(c) for c in s).decode("utf-8")
    except UnicodeDecodeError:
        return None
    if out == s:
        return None
    # Prefer repairs that introduce CJK or fullwidth punctuation.
    if any("\u4e00" <= c <= "\u9fff" for c in out) or "。" in out or "，" in out:
        return out
    # Also accept arrow / dash repairs for comments
    if "—" in out or "→" in out or "–" in out:
        return out
    return None


def fix_file(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    changed = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal changed
        inner = m.group(1)
        if not looks_mojibake(inner):
            return m.group(0)
        fixed = repair(inner)
        if fixed is None:
            return m.group(0)
        changed += 1
        return '"' + fixed + '"'

    new_text = STR_RE.sub(repl, text)
    # Also repair common comment mojibake outside strings (em dash etc.)
    for bad, good in (
        ("â", "—"),
        ("Ã¢ÂÂ", "—"),
        ("â", "→"),
    ):
        if bad in new_text:
            new_text = new_text.replace(bad, good)
            changed += 1
    if new_text != text:
        path.write_text(new_text, encoding="utf-8", newline="\n")
    return changed


def main() -> int:
    total = 0
    for p in TARGETS:
        n = fix_file(p)
        print(f"{p.relative_to(ROOT)}: {n} string repairs")
        total += n
    print(f"TOTAL {total}")
    return 0 if total >= 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
