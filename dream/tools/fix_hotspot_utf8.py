# -*- coding: utf-8 -*-
"""One-shot: restore UTF-8 Chinese hotspot titles in residential assemblers."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fix_village() -> None:
	path = ROOT / "scripts/areas/village_residential_assembler.gd"
	text = path.read_text(encoding="utf-8")
	new_slots = '''func _house_slots() -> Array:
	# South-facing cottages NORTH of their door lane — foot Y leaves full sprite inside PLAY_ZONE.
	return [
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(288, 520),
			"hw": 2, "hh": 1,
			"title": "西巷民居",
			"desc": "主巷北侧住宅：整栋在住宅区内，门朝南。",
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(544, 520),
			"hw": 2, "hh": 1,
			"title": "中巷民居",
			"desc": "主巷中段北侧宅院。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(800, 520),
			"hw": 2, "hh": 1,
			"title": "东巷民居",
			"desc": "主巷东段北侧小屋。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(1000, 520),
			"hw": 2, "hh": 1,
			"title": "东角宅",
			"desc": "东段住宅，整栋在区内。",
		},
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(400, 280),
			"hw": 2, "hh": 1,
			"title": "北排西宅",
			"desc": "北巷北侧住宅：屋顶不穿出地图上沿。",
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(656, 280),
			"hw": 2, "hh": 1,
			"title": "北排中宅",
			"desc": "北巷中段宅院。",
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(912, 280),
			"hw": 2, "hh": 1,
			"title": "北排东宅",
			"desc": "北巷东端住宅。",
		},
	]
'''
	m = re.search(r"func _house_slots\(\) -> Array:.*?^\t\]\n", text, re.M | re.S)
	if not m:
		raise SystemExit("village: _house_slots not found")
	path.write_text(text[: m.start()] + new_slots + text[m.end() :], encoding="utf-8", newline="\n")
	print("fixed", path)


def fix_farm() -> None:
	path = ROOT / "scripts/areas/farm_residential_assembler.gd"
	text = path.read_text(encoding="utf-8")
	text = text.replace(
		"Foot Y â‰¥ ~352: margin past FARM_BUILD_ZONE top after tall-cottage AABB.",
		"Foot Y ≥ ~352: margin past FARM_BUILD_ZONE top after tall-cottage AABB.",
	)
	pairs = [
		("building_02.png", "农舍", "农舍完整落在院落围栏内：门朝南对土路。"),
		("building_04.png", "鸡舍", "西北鸡舍，整栋在围栏内侧。"),
		("building_01.png", "谷仓", "东北谷仓，整栋在围栏内侧。"),
	]
	for path_key, title, desc in pairs:
		pattern = (
			rf'("path": "res://assets/sprites/buildings/{re.escape(path_key)}",\n'
			rf'\t\t\t"pos": Vector2\([^)]+\),\n'
			rf'\t\t\t"hw": 2, "hh": 1,\n'
			rf'\t\t\t"title": ")[^"]+(",\n'
			rf'\t\t\t"desc": ")[^"]+(",)'
		)
		text, n = re.subn(pattern, rf"\g<1>{title}\g<2>{desc}\g<3>", text, count=1)
		print(path_key, "n=", n)
		if n != 1:
			raise SystemExit(f"farm: failed to replace {path_key}")
	path.write_text(text, encoding="utf-8", newline="\n")
	print("fixed", path)


if __name__ == "__main__":
	fix_village()
	fix_farm()
