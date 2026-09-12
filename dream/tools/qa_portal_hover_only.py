#!/usr/bin/env python3
"""Portal arch must not use always-on tween pulse (hover modulate only)."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FILES = [
	ROOT / "scripts/areas/area_craft.gd",
	ROOT / "scripts/world/world_spawn_util.gd",
	ROOT / "scripts/interiors/interior_craft.gd",
]
BAD = "var pulse := arch.create_tween().set_loops()"


def main() -> int:
	fails: list[str] = []
	for path in FILES:
		text = path.read_text(encoding="utf-8")
		if BAD in text:
			fails.append(f"{path.relative_to(ROOT)} still has always-on arch pulse")
	if fails:
		print("RED portal hover-only QA")
		for f in fails:
			print(" -", f)
		return 1
	print("GREEN portal hover-only QA (no always-on arch pulse)")
	return 0


if __name__ == "__main__":
	sys.exit(main())
