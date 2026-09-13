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
	kit = (ROOT / "scripts/world/outdoor_lamp_kit.gd").read_text(encoding="utf-8")
	if 'ends_with("/lamp_2.png")' in kit and "return p.ends_with" in kit:
		# Street-lamp path matcher must not OR lamp_2 (planter).
		for line in kit.splitlines():
			if "return p.ends_with" in line and "lamp_2" in line:
				raise AssertionError("OutdoorLampKit must not treat lamp_2 planter as street lamp")

	must(
		ROOT / "scripts/env/day_night_weather.gd",
		"scripts/world/outdoor_lamp_kit.gd",
		"Color(0.28, 0.32, 0.48",
	)
	must(
		ROOT / "scripts/world/world_spawn_util.gd",
		"tex_scale: float = 1.05",
		"size_px: int = 256",
		"LAMP_ENERGY_NIGHT := 1.55",
		"LAMP_TEX_SCALE := 1.05",
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
