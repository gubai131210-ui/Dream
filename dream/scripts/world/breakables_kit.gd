class_name BreakablesKit
extends RefCounted

## C59 — ≥4 clearable props. Wave F WorldSys places on square/farm edge.

const KINDS := ["rock", "stake", "weed", "crate"]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in KINDS:
		out.append({"id": id, "title": "可清:" + id, "hint": "破坏占位"})
	return out
