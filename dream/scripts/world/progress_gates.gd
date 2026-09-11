class_name ProgressGates
extends RefCounted

## C60 — ≥3 progress gates (log / boulder / locked door). Wave F WorldSys.

const GATES := ["fallen_log", "boulder", "locked_door"]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in GATES:
		out.append({"id": id, "title": "障碍:" + id, "hint": "进度门占位"})
	return out
