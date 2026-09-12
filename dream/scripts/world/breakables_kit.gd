class_name BreakablesKit
extends Node

## C59 — ≥4 clearable breakables on village_square (click to remove).

const NODE_NAME := "BreakablesKit"

const KIND_DEFS := [
	{"id": "rock", "title": "碎石堆", "desc": "砸开碎石，清出小路。", "pos": Vector2(150, 680), "color": Color(0.55, 0.55, 0.58, 0.95), "sprite": "res://assets/sprites/props/rock_02.png", "scale": 0.55},
	{"id": "stake", "title": "木桩", "desc": "拔起旧木桩。", "pos": Vector2(1180, 360), "color": Color(0.62, 0.42, 0.28, 0.95), "sprite": "res://assets/sprites/props/breakable_stake_00.png", "scale": 0.7},
	{"id": "weed", "title": "杂草丛", "desc": "割净杂草。", "pos": Vector2(760, 720), "color": Color(0.4, 0.7, 0.35, 0.95), "sprite": "res://assets/sprites/props/breakable_weed_00.png", "scale": 0.65},
	{"id": "crate", "title": "破箱", "desc": "砸开废弃破箱。", "pos": Vector2(1040, 240), "color": Color(0.7, 0.48, 0.3, 0.95), "sprite": "res://assets/sprites/props/crate_2.png", "scale": 0.55},
]

signal cleared(kind_id: String)

var _info: InfoPanel
var _root: Node2D
var _cleared: Dictionary = {}


static func attach_to(host: Node2D, top_bar: Control = null) -> BreakablesKit:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as BreakablesKit
	if existing:
		return existing
	var kit := BreakablesKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for d in KIND_DEFS:
		out.append({"id": d["id"], "title": d["title"], "hint": d["desc"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


func setup(host: Node2D, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "BreakablesRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	for d in KIND_DEFS:
		_spawn_one(d)


func live_count() -> int:
	return KIND_DEFS.size()


func cleared_count() -> int:
	return _cleared.size()


func _spawn_one(d: Dictionary) -> void:
	var kind_id := str(d["id"])
	var title := str(d["title"])
	var desc := str(d["desc"])
	var hs := WorldSpawnUtil.make_hotspot(
		_root,
		title,
		desc + "（点击清除）",
		d["pos"] as Vector2,
		Vector2(52, 44),
		d["color"] as Color,
		str(d.get("sprite", "")),
		float(d.get("scale", 0.55)),
	)
	hs.set_meta("breakable_id", kind_id)
	hs.activated.connect(func(h: InteractableHotspot) -> void:
		_clear_breakable(kind_id, title, h)
	)


func _clear_breakable(kind_id: String, title: String, hs: InteractableHotspot) -> void:
	if _cleared.has(kind_id):
		return
	_cleared[kind_id] = true
	if _info:
		_info.show_info(title, "已清除「%s」。" % title)
	cleared.emit(kind_id)
	if is_instance_valid(hs):
		hs.queue_free()
