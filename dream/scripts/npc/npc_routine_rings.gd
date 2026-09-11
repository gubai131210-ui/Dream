class_name NpcRoutineRings
extends RefCounted

## C53 work rings + C54 life rings — Wave F NpcRing team enriches.
## Mount via thin hooks on square/market/C02; do not rewrite assemblers wholesale.

const WORK_RING_IDS := ["sow", "smith", "stall", "fish", "cook"]
const LIFE_STATE_IDS := ["eat", "sleep", "read", "laundry", "idle_sit"]


static func work_demo_waypoints() -> Array:
	## ≥3 work rings (placeholder anchors — team replaces with real outdoor/indoor anchors).
	return [
		{"id": "sow", "title": "播种环", "scene": "farmland", "hint": "田垄工作环（占位）"},
		{"id": "smith", "title": "打铁环", "scene": "c04_smith", "hint": "铁匠工作环（占位）"},
		{"id": "stall", "title": "摆货环", "scene": "market", "hint": "摊位摆货环（占位）"},
	]


static func life_demo_states() -> Array:
	## ≥3 life states (placeholder — team wires to C02 actor stands).
	return [
		{"id": "eat", "title": "用餐", "hint": "餐桌生活态（占位）"},
		{"id": "sleep", "title": "睡眠", "hint": "床区生活态（占位）"},
		{"id": "read", "title": "阅读", "hint": "摇椅/灯下阅读（占位）"},
	]
