class_name WorldInteractKit
extends RefCounted

## C58 — ≥8 world interact types. Wave F WorldSys wires hotspots on village_square.

const INTERACT_TYPES := [
	"sit_bench", "well_water", "shake_tree", "notice_board", "crate_search",
	"lamp_toggle", "feed_critter", "read_sign",
]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in INTERACT_TYPES:
		out.append({"id": id, "title": id, "hint": "交互占位 — WorldSys 接线"})
	return out
