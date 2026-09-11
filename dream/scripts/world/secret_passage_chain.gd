class_name SecretPassageChain
extends RefCounted

## C62 — ≥1 cross-map secret chain. Wave F WorldSys wires portals.

const CHAIN_A := [
	{"from": "forest_deep", "label": "树洞密道", "to": "c16_cave_entry"},
	{"from": "c16_cave_entry", "label": "暗河出口", "to": "waterfall"},
	{"from": "waterfall", "label": "瀑后回湖", "to": "lake"},
]


static func stub_chain() -> Array:
	return CHAIN_A
