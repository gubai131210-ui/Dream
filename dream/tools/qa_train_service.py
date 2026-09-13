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
	if "TrainCarWindowRide" in room:
		raise AssertionError("C36 must not attach window scenery ride")
	if "notify_player_entered_car" not in room:
		raise AssertionError("C36 must still notify TrainService on enter")
	if "_seat_wheels_on_rails" not in rt or "RAIL_Y" not in rt:
		raise AssertionError("train runtime missing wheel-on-rail seating")
	if "_spawn_driving_wheels" not in rt or "CPUParticles2D" not in rt or "TrailSmoke" not in rt:
		raise AssertionError("train runtime missing wheel spin / steam plume FX")
	assets = [
		"assets/sprites/props/train_loco_00.png",
		"assets/sprites/props/train_coach_00.png",
		"assets/sprites/props/train_consist_00.png",
		"assets/sprites/props/train_wheel_00.png",
		"assets/sprites/props/track_band_seamless_00.png",
		"assets/sprites/fx/train_steam_00.png",
		"assets/sprites/props/train_ticket_00.png",
		"assets/sprites/interior/props/train_window_wall_00.png",
		"assets/sprites/interior/props/train_seat_row_00.png",
		"assets/sprites/interior/props/train_passenger_a_00.png",
		"assets/sprites/interior/props/train_passenger_b_00.png",
		"assets/sprites/interior/props/train_passenger_c_00.png",
		"assets/sprites/interior/props/train_suitcase_00.png",
		"assets/sprites/interior/props/train_mail_pouch_00.png",
	]
	asm = (ROOT / "scripts/areas/station_assembler.gd").read_text(encoding="utf-8")
	if "track_band_seamless_00" not in asm or "TrackBandContinuous" not in asm:
		raise AssertionError("station assembler missing continuous seamless track band")
	if "TRACK_TX0 := 0" not in asm:
		raise AssertionError("tracks must start at left map edge (TRACK_TX0 := 0)")
	prof = (ROOT / "scripts/interiors/interior_profiles.gd").read_text(encoding="utf-8")
	if "P_TRAIN_WINDOW_WALL" not in prof or "train_window_wall_00" not in prof:
		raise AssertionError("C36 profile missing train window wall")
	if "P_TRAIN_PASS_A" not in prof or "train_passenger_a_00" not in prof:
		raise AssertionError("C36 profile missing seated passengers")
	idx = prof.find('"c36_train_car"')
	chunk = prof[idx : idx + 2200]
	if '"window": false' not in chunk:
		raise AssertionError("c36 must disable generic house window/shaft")
	if "P_BASKET" in chunk or "P_CRATE0" in chunk or "P_FERRY_SCHEDULE" in chunk:
		raise AssertionError("c36 still has non-coach clutter props")
	if "窗外景色" in chunk or "站外景色" in chunk:
		raise AssertionError("c36 copy still promises outdoor window scenery")
	for rel in assets:
		if not (ROOT / rel).is_file():
			raise AssertionError(f"missing asset {rel}")
	if (ROOT / "scripts/interiors/train_car_window_ride.gd").is_file():
		raise AssertionError("train_car_window_ride.gd should be removed")
	print("GREEN train-service QA (autoload, runtime, gate, coach passengers, no window scenery)")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as exc:
		print(f"RED train-service QA: {exc}")
		raise SystemExit(1)
