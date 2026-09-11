class_name HiddenChests
extends RefCounted

## C61 — ≥5 hidden chest sites. Wave F WorldSys places across explore maps.

const SITES := ["tree_behind", "waterfall", "cave", "well", "island"]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in SITES:
		out.append({"id": id, "title": "箱:" + id, "hint": "隐藏箱占位"})
	return out
