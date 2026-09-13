#!/usr/bin/env python3
"""QA: world sim loop — global env, immersive chrome, weather building FX, schedules."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def must(path: Path, *needles: str) -> None:
	text = path.read_text(encoding="utf-8")
	for n in needles:
		if n not in text:
			raise AssertionError(f"{path.relative_to(ROOT)} missing `{n}`")


def main() -> int:
	proj = (ROOT / "project.godot").read_text(encoding="utf-8")
	if "WorldEnvState=" not in proj:
		raise AssertionError("project.godot missing WorldEnvState autoload")
	if "ScheduleDirector=" not in proj:
		raise AssertionError("project.godot missing ScheduleDirector autoload")

	must(
		ROOT / "scripts/world/world_env_state.gd",
		"enum WeatherKind { CLEAR, RAIN, SNOW, FOG }",
		"signal state_changed",
	)
	must(
		ROOT / "scripts/env/day_night_weather.gd",
		"WorldEnvState",
		"WeatherKind.SNOW",
		"weather_building_fx.gd",
		"map_travel_kit.gd",
	)
	must(
		ROOT / "scripts/ui/dream_ui.gd",
		"_hide_play_chrome",
		"PlayKeysHint",
	)
	must(
		ROOT / "scripts/world/map_travel_kit.gd",
		"KEY_BRACKETLEFT",
		"SceneRouter.change_to",
		"OUTDOOR_RING",
	)
	must(
		ROOT / "scripts/world/weather_building_fx.gd",
		"EaveDrip",
		"SnowCap",
		"/buildings/",
	)
	must(
		ROOT / "scripts/world/schedule_director.gd",
		"hidden_home",
		"ambient_critters",
		"patrol_actors",
	)
	must(ROOT / "docs/WORLD_SIM_LOOP.md", "禁止偷懒", "WorldEnvState")
	print("GREEN world-sim-loop QA")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as e:
		print("RED", e)
		raise SystemExit(1)
