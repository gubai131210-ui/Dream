#!/usr/bin/env python3
"""QA gates for Spine A + Farm B + Encounter D package."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def must_contain(path: Path, *needles: str) -> None:
	text = path.read_text(encoding="utf-8")
	for n in needles:
		if n not in text:
			raise AssertionError(f"{path.relative_to(ROOT)} missing `{n}`")


def must_exist(*rels: str) -> None:
	for rel in rels:
		if not (ROOT / rel).is_file():
			raise AssertionError(f"missing asset {rel}")


def main() -> int:
	proj = (ROOT / "project.godot").read_text(encoding="utf-8")
	if "SpawnRegistry=" not in proj:
		raise AssertionError("SpawnRegistry autoload missing")
	if "InventoryService=" not in proj:
		raise AssertionError("InventoryService autoload missing")

	must_contain(
		ROOT / "scripts/core/scene_router.gd",
		"spawn_id: String = \"\"",
		'call("set_pending"',
	)
	must_contain(
		ROOT / "scripts/core/player_bootstrap.gd",
		'call("has_pending")',
		'call("take_pending")',
		"Spawn_",
		'call("default_local_pos"',
		"Vector2(0, 48.0)",
		"arm_portal_grace",
	)
	must_contain(
		ROOT / "scripts/world/inventory_service.gd",
		"try_add",
		"try_remove",
		"seed_turnip",
		"crop_turnip",
		"loot_moss_resin",
		"loot_ruin_shard",
	)
	must_contain(
		ROOT / "scripts/world/world_spawn_util.gd",
		"spawn_id",
		"SceneRouter.change_to(tree, path, sid)",
	)

	# B — farm
	must_contain(
		ROOT / "scripts/farm/farm_crop_kit.gd",
		"FarmCropKit",
		"crop_turnip_stage_00",
		"crop_tilled_patch_00",
		"crop_till_dust_00",
		"crop_water_splash_00",
		"crop_harvest_spark_00",
		'"tilled"',
		"_morning_tick",
		'call("try_add"',
		'call("try_remove"',
	)
	must_contain(
		ROOT / "scripts/world/spawn_registry.gd",
		"arm_portal_grace",
		"portal_grace_active",
	)
	must_contain(
		ROOT / "scripts/world/walk_contract.gd",
		"WalkContract",
		"FOOT_CONTACT_Y",
		"Area2D",
	)
	must_contain(
		ROOT / "scripts/core/player_bootstrap.gd",
		"arm_portal_grace",
	)
	must_contain(
		ROOT / "scripts/actors/player_actor.gd",
		"FOOT_CONTACT_Y := 0.0",
		"is_npc_walkable",
	)
	must_contain(
		ROOT / "scripts/areas/farmland_controller.gd",
		"scripts/farm/farm_crop_kit.gd",
		"WorldSpawnUtil.wire_portal_click",
	)
	must_contain(
		ROOT / "scripts/env/day_night_weather.gd",
		"signal state_changed",
		"enum TimeGrade { DAY, NIGHT }",
	)

	# D — encounter
	must_contain(
		ROOT / "scripts/world/encounter_pocket_kit.gd",
		"EncounterPocketKit",
		"moss_blob_00",
		"ruin_cache_urn_00",
		"loot_moss_resin",
		"HITS_TO_CLEAR",
	)
	must_contain(
		ROOT / "scripts/interiors/interior_room_controller.gd",
		'profile_id == "c29_ruins"',
		"scripts/world/encounter_pocket_kit.gd",
	)
	must_contain(
		ROOT / "scripts/areas/forest_deep_assembler.gd",
		'set_meta("spawn_id", "entrance")',
	)
	must_contain(
		ROOT / "scripts/areas/forest_deep_controller.gd",
		"WorldSpawnUtil.wire_portal_click",
	)
	must_contain(
		ROOT / "scripts/interiors/interior_profiles.gd",
		'"return_spawn_id": "from_ruins"',
	)
	must_contain(
		ROOT / "scripts/world/train_service.gd",
		"苔树脂",
	)

	# Safety: kits must not be attached on square/station/farmland for encounter
	sq = (ROOT / "scripts/areas/village_square_controller.gd").read_text(encoding="utf-8")
	if "EncounterPocketKit" in sq:
		raise AssertionError("EncounterPocketKit must not attach on village square")
	st = (ROOT / "scripts/areas/station_controller.gd").read_text(encoding="utf-8")
	if "EncounterPocketKit" in st:
		raise AssertionError("EncounterPocketKit must not attach on station")
	fm = (ROOT / "scripts/areas/farmland_controller.gd").read_text(encoding="utf-8")
	if "EncounterPocketKit" in fm:
		raise AssertionError("EncounterPocketKit must not attach on farmland")

	must_exist(
		"assets/sprites/props/crop_turnip_stage_00.png",
		"assets/sprites/props/crop_turnip_stage_01.png",
		"assets/sprites/props/crop_turnip_stage_02.png",
		"assets/sprites/props/crop_turnip_stage_03.png",
		"assets/sprites/props/crop_tilled_patch_00.png",
		"assets/sprites/fx/crop_till_dust_00.png",
		"assets/sprites/fx/crop_water_splash_00.png",
		"assets/sprites/fx/crop_harvest_spark_00.png",
		"assets/sprites/props/moss_blob_00.png",
		"assets/sprites/props/moss_blob_hurt_00.png",
		"assets/sprites/props/loot_moss_resin_00.png",
		"assets/sprites/props/loot_ruin_shard_00.png",
		"assets/sprites/fx/moss_clear_fx_00.png",
		"assets/sprites/props/ruin_cache_urn_00.png",
		"docs/GOAL_SPINE_ABD.md",
		"docs/research/PLAYER_SPINE_A_RESEARCH.md",
		"docs/research/FARM_CROP_B_RESEARCH.md",
		"docs/research/ENEMY_LOOT_GAMEPLAY_RESEARCH.md",
	)

	print("GREEN spine-ABD QA (autoloads, spawn, inventory, farm crop, encounter pocket, new art)")
	return 0


if __name__ == "__main__":
	try:
		raise SystemExit(main())
	except AssertionError as e:
		print("RED", e)
		raise SystemExit(1)
