#!/usr/bin/env python3
"""QA: scene placement + biome rock taxonomy."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def must(path: Path, *needles: str) -> None:
	text = path.read_text(encoding="utf-8")
	for n in needles:
		if n not in text:
			raise AssertionError(f"{path.relative_to(ROOT)} missing `{n}`")


def main() -> int:
	must(
		ROOT / "scripts/areas/area_craft.gd",
		"allow_blocked",
		"is_blocked(nx, ny)",
	)
	must(
		ROOT / "scripts/world/rock_catalog.gd",
		"FAMILY_COASTAL",
		"FAMILY_TERRACE",
		"FAMILY_RIVER_BANK",
		"TARGET_H_SHORE",
	)
	for fam in ("coastal", "terrace", "cobble", "river"):
		p = ROOT / "assets/sprites/props/rocks" / fam / "rock_00.png"
		if not p.is_file():
			raise AssertionError(f"missing biome rock {p.relative_to(ROOT)}")
	must(ROOT / "scripts/areas/waterfall_assembler.gd", "FAMILY_RIVER_BANK", "170, 340")
	must(ROOT / "scripts/areas/lake_assembler.gd", "Vector2(640, 760)")
	must(ROOT / "scripts/areas/hill_farm_assembler.gd", "FAMILY_TERRACE")
	must(ROOT / "scripts/areas/lighthouse_assembler.gd", "FAMILY_COASTAL", "_spawn_rocks(ysort)")
	must(ROOT / "scripts/areas/village_residential_assembler.gd", "_spawn_se_pond_rock")
	must(ROOT / "docs/SCENE_PLACEMENT_AUDIT.md", "禁止偷懒")
	print("GREEN scene-placement + biome-rocks QA")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as e:
		print("RED", e)
		raise SystemExit(1)
