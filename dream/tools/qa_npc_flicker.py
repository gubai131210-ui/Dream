#!/usr/bin/env python3
"""QA: NPC patrol flicker guards."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def must(path: Path, *needles: str) -> None:
	text = path.read_text(encoding="utf-8")
	for n in needles:
		if n not in text:
			raise AssertionError(f"{path.relative_to(ROOT)} missing `{n}`")


def forbid(path: Path, *needles: str) -> None:
	text = path.read_text(encoding="utf-8")
	for n in needles:
		if n in text:
			raise AssertionError(f"{path.relative_to(ROOT)} still has `{n}`")


def main() -> int:
	must(
		ROOT / "scripts/actors/patrol_actor.gd",
		"FACING_BIAS",
		"_anim_walking",
		"_update_facing(dir)",  # sidestep keeps route facing
	)
	patrol = (ROOT / "scripts/actors/patrol_actor.gd").read_text(encoding="utf-8")
	# Pause path must not call _set_anim(false) unconditionally every tick.
	if "_pause_left > 0.0:" in patrol:
		block = patrol.split("if _pause_left > 0.0:")[1].split("return")[0]
		if "_set_anim(false)" in block and "if _moving:" not in block:
			raise AssertionError("pause path still resets anim every tick")
	must(
		ROOT / "scripts/world/schedule_director.gd",
		"mode_changed",
		"if not mode_changed:",
	)
	dn = (ROOT / "scripts/env/day_night_weather.gd").read_text(encoding="utf-8")
	# _on_global should not re-call ScheduleDirector.apply (double apply).
	on_global = dn.split("func _on_global")[1].split("func ")[0]
	if "apply_to_current_scene" in on_global:
		raise AssertionError("DayNightWeather._on_global still double-applies ScheduleDirector")
	print("GREEN npc-flicker QA")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as e:
		print("RED", e)
		raise SystemExit(1)
