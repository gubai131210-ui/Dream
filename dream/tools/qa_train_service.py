#!/usr/bin/env python3
"""QA gates for train service wiring + assets."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
	proj = (ROOT / "project.godot").read_text(encoding="utf-8")
	if "TrainService=" not in proj:
		raise AssertionError("TrainService autoload missing from project.godot")
	svc = (ROOT / "scripts/world/train_service.gd").read_text(encoding="utf-8")
	for needle in ("enum State", "try_buy_ticket_from_booth", "night_express", "lake_coast", "local_hill"):
		if needle not in svc:
			raise AssertionError(f"TrainService missing {needle}")
	rt = (ROOT / "scripts/areas/station_train_runtime.gd").read_text(encoding="utf-8")
	if "train_loco_00" not in rt or "APPROACHING" not in rt:
		raise AssertionError("StationTrainRuntime missing loco / state handling")
	ctrl = (ROOT / "scripts/areas/station_controller.gd").read_text(encoding="utf-8")
	if "StationTrainRuntime.attach_to" not in ctrl:
		raise AssertionError("station controller missing train runtime")
	if "TrainService.can_board_car" not in ctrl:
		raise AssertionError("station controller missing coach board gate")
	room = (ROOT / "scripts/interiors/interior_room_controller.gd").read_text(encoding="utf-8")
	if "TrainCarWindowRide" not in room:
		raise AssertionError("C36 window ride not wired")
	assets = [
		"assets/sprites/props/train_loco_00.png",
		"assets/sprites/props/train_coach_00.png",
		"assets/sprites/fx/train_steam_00.png",
		"assets/sprites/fx/train_window_scenery_00.png",
		"assets/sprites/props/train_ticket_00.png",
	]
	for rel in assets:
		if not (ROOT / rel).is_file():
			raise AssertionError(f"missing asset {rel}")
	print("GREEN train-service QA (autoload, runtime, gate, window ride, assets)")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as exc:
		print(f"RED train-service QA: {exc}")
		raise SystemExit(1)
