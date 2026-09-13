#!/usr/bin/env python3
"""QA: outdoor night lamps get PointLight2D + CanvasModulate-compensated energy."""
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
		ROOT / "scripts/world/outdoor_lamp_kit.gd",
		"OutdoorLampKit",
		"ENERGY_NIGHT",
		"PointLight2D",
		"lamp_0.png",
		"LAMP0_SCALE",
	)
	must(
		ROOT / "scripts/env/day_night_weather.gd",
		"scripts/world/outdoor_lamp_kit.gd",
		"Color(0.22, 0.26, 0.42",
	)
	must(
		ROOT / "scripts/world/world_spawn_util.gd",
		"tex_scale: float = 2.4",
		"size_px: int = 256",
	)
	must(
		ROOT / "scripts/world/world_interact_kit.gd",
		'"scale": 1.15',
		"WorldSpawnUtil.LAMP_ENERGY_NIGHT",
	)
	must(
		ROOT / "scripts/world/district_interact_kit.gd",
		"WorldSpawnUtil.LAMP_ENERGY_NIGHT",
		'"scale": 1.15',
	)
	must(
		ROOT / "scripts/world/world_spawn_util.gd",
		"LAMP_ENERGY_NIGHT",
		"LAMP_SPRITE_SCALE",
	)
	# Misnamed flower-pot-as-lamp removed from station/residential.
	st = (ROOT / "scripts/areas/station_assembler.gd").read_text(encoding="utf-8")
	if 'lamp_1.png", "pos": Vector2(1040, 352), "title": "站台灯"' in st:
		raise AssertionError("station still uses lamp_1 flower pot as 站台灯")
	res = (ROOT / "scripts/areas/village_residential_assembler.gd").read_text(encoding="utf-8")
	if "lamp_1.png" in res and "路灯" in res:
		# Allow only if not titled 路灯 on same entry — coarse check:
		if 'lamp_1.png", "pos": Vector2(880, 480), "title": "路灯"' in res:
			raise AssertionError("residential still uses lamp_1 as 路灯")
	print("GREEN outdoor-lamp night glow QA")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as e:
		print("RED", e)
		raise SystemExit(1)
