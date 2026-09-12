class_name ProgressGates
extends Node

## C60 — ≥3 progress gates with unlock stub (click → unlock / clear).

const NODE_NAME := "ProgressGates"

const GATE_DEFS := [
	{
		"id": "fallen_log",
		"title": "倒木",
		"locked": "倒下的粗木挡住了小路。点击解锁（剧情/工具桩）。",
		"unlocked": "倒木已移开，小路通畅。",
		"pos": Vector2(200, 780),
		"color": Color(0.5, 0.35, 0.22, 0.95),
		"sprite": "res://assets/sprites/props/gate_log_00.png",
		"scale": 0.65,
	},
	{
		"id": "boulder",
		"title": "巨石",
		"locked": "巨石堵住捷径。点击解锁（升级桩）。",
		"unlocked": "巨石滚到路旁，捷径打开。",
		"pos": Vector2(1120, 760),
		"color": Color(0.5, 0.52, 0.55, 0.95),
		"sprite": "res://assets/sprites/props/rock_04.png",
		"scale": 0.7,
	},
	{
		"id": "locked_door",
		"title": "锁门",
		"locked": "铁锁门紧闭。点击解锁（钥匙桩）。",
		"unlocked": "锁已打开，门扇轻推即入。",
		"pos": Vector2(80, 480),
		"color": Color(0.55, 0.45, 0.65, 0.95),
		"sprite": "res://assets/sprites/props/door_facade_00.png",
		"scale": 0.5,
	},
]

signal unlocked(gate_id: String)

var _info: InfoPanel
var _root: Node2D
var _unlocked: Dictionary = {}


static func attach_to(host: Node2D, top_bar: Control = null) -> ProgressGates:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as ProgressGates
	if existing:
		return existing
	var kit := ProgressGates.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for d in GATE_DEFS:
		out.append({"id": d["id"], "title": d["title"], "hint": d["locked"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


func setup(host: Node2D, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "ProgressGatesRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	for d in GATE_DEFS:
		_spawn_one(d)


func live_count() -> int:
	return GATE_DEFS.size()


func unlocked_count() -> int:
	return _unlocked.size()


func is_unlocked(gate_id: String) -> bool:
	return bool(_unlocked.get(gate_id, false))


func unlock(gate_id: String) -> void:
	if _unlocked.get(gate_id, false):
		return
	_unlocked[gate_id] = true
	unlocked.emit(gate_id)
	for child in _root.get_children():
		if child is InteractableHotspot and str(child.get_meta("gate_id", "")) == gate_id:
			var hs := child as InteractableHotspot
			hs.description = "已解锁。"
			var visual := hs.get_node_or_null("Visual/Marker") as Polygon2D
			if visual:
				visual.color = Color(0.45, 0.85, 0.5, 0.85)
			var tag := hs.get_node_or_null("Visual/Tag") as Label
			if tag:
				tag.text = hs.title + "·通"
			var spr := hs.get_node_or_null("Visual/PropSprite") as Sprite2D
			if spr:
				spr.modulate = Color(0.7, 0.9, 0.7, 0.45)
			break


func _spawn_one(d: Dictionary) -> void:
	var gate_id := str(d["id"])
	var title := str(d["title"])
	var locked := str(d["locked"])
	var unlocked_msg := str(d["unlocked"])
	var hs := WorldSpawnUtil.make_hotspot(
		_root,
		title,
		locked,
		d["pos"] as Vector2,
		Vector2(64, 52),
		d["color"] as Color,
		str(d.get("sprite", "")),
		float(d.get("scale", 0.55)),
	)
	hs.set_meta("gate_id", gate_id)
	hs.activated.connect(func(h: InteractableHotspot) -> void:
		if is_unlocked(gate_id):
			if _info:
				_info.show_info(title, unlocked_msg)
			return
		unlock(gate_id)
		if _info:
			_info.show_info(title, unlocked_msg)
		h.modulate = Color(1, 1, 1, 0.35)
	)
