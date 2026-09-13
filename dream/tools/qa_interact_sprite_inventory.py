#!/usr/bin/env python3
"""Verify shipped interact sprite paths exist on disk (C58/C59/C60/district/market)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def extract_res_pngs(text: str) -> list[str]:
	paths = re.findall(r'res://assets/[^"\']+\.png', text)
	# Skip GDScript format templates like chest_lid_%02d.png
	return [p for p in paths if "%" not in p]


def must_exist(paths: list[str], label: str) -> list[str]:
	missing: list[str] = []
	for p in paths:
		rel = p.replace("res://", "")
		if not (ROOT / rel).exists():
			missing.append(f"{label}: {p}")
	return missing


def main() -> int:
	missing: list[str] = []
	files = {
		"world_interact": ROOT / "scripts/world/world_interact_kit.gd",
		"breakables": ROOT / "scripts/world/breakables_kit.gd",
		"gates": ROOT / "scripts/world/progress_gates.gd",
		"district": ROOT / "scripts/world/district_interact_kit.gd",
		"chests": ROOT / "scripts/world/hidden_chests.gd",
		"market": ROOT / "scripts/market/market_stall.gd",
		"fishing": ROOT / "scripts/fishing/fishing_spot.gd",
		"cage": ROOT / "scripts/fishing/fish_cage.gd",
	}
	for label, path in files.items():
		text = path.read_text(encoding="utf-8")
		missing.extend(must_exist(extract_res_pngs(text), label))

	# Focus / FX that hover + open clips require
	for p in (
		"assets/sprites/fx/focus_corners_00.png",
		"assets/sprites/fx/fish_ring_00.png",
		"assets/sprites/fx/leaf_fall_00.png",
		"assets/sprites/fx/bird_peck_00.png",
		"assets/sprites/fx/board_rustle_00.png",
		"assets/sprites/fx/bench_dust_00.png",
		"assets/sprites/fx/window_light_shaft_00.png",
		"assets/sprites/interior/props/drawer_open_00.png",
		"assets/sprites/props/chest_lid_00.png",
		"assets/sprites/props/well_rope_00.png",
		"assets/sprites/props/crate_lid_00.png",
	):
		if not (ROOT / p).exists():
			missing.append(f"fx: res://{p}")

	# Landmark props for Wave C investigate hotspots (must own PropSprite).
	for p in (
		"assets/sprites/props/reed_clump_00.png",
		"assets/sprites/props/ruin_arch_00.png",
		"assets/sprites/props/grave_marker_00.png",
		"assets/sprites/props/bridge_plank_00.png",
		"assets/sprites/trees/grounded/tree_00.png",
		"assets/sprites/trees/grounded/tree_04.png",
		"assets/sprites/props/boat_skiff_00.png",
		"assets/sprites/props/track_rail_00.png",
		"assets/sprites/props/track_sleeper_00.png",
		"assets/sprites/market/stall_awning_00.png",
	):
		if not (ROOT / p).exists():
			missing.append(f"landmark: res://{p}")

	# C58 shake_tree must ship formal tree prop (no polygon canopy production path).
	wik = (ROOT / "scripts/world/world_interact_kit.gd").read_text(encoding="utf-8")
	if "TreeCanopyCue" in wik or "_setup_tree_marker" in wik:
		missing.append("world_interact: polygon tree canopy fallback still present")
	if "trees/grounded/tree_00.png" not in wik:
		missing.append("world_interact: shake_tree must reference tree_00.png")
	if re.search(r'"id":\s*"shake_tree"[\s\S]*?"scale":\s*0\.0', wik):
		missing.append("world_interact: shake_tree scale must be > 0 (prop required)")

	if missing:
		print("FAIL interact sprite inventory")
		for m in missing:
			print(" ", m)
		return 1
	print("GREEN interact sprite inventory (kits + focus/open FX)")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
