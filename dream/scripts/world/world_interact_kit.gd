class_name WorldInteractKit
extends Node

## C58 — ≥8 world interact types as live hotspots on village_square.

const NODE_NAME := "WorldInteractKit"

const INTERACT_DEFS := [
	{"id": "sit_bench", "title": "长椅", "desc": "坐一会儿，听广场闲谈。", "pos": Vector2(420, 620), "color": Color(0.72, 0.55, 0.32, 0.92)},
	{"id": "well_water", "title": "井水", "desc": "打一桶清凉井水。", "pos": Vector2(640, 540), "color": Color(0.4, 0.7, 0.95, 0.92)},
	{"id": "shake_tree", "title": "摇树", "desc": "摇晃庭树，落下一片叶子。", "pos": Vector2(180, 300), "color": Color(0.35, 0.75, 0.4, 0.92)},
	{"id": "notice_board", "title": "公告栏", "desc": "本周集市与庆典告示。", "pos": Vector2(860, 280), "color": Color(0.9, 0.78, 0.4, 0.92)},
	{"id": "crate_search", "title": "木箱", "desc": "翻找补给箱，空空如也。", "pos": Vector2(1100, 620), "color": Color(0.7, 0.5, 0.3, 0.92)},
	{"id": "lamp_toggle", "title": "路灯", "desc": "拨亮/熄灭广场路灯（本地示意）。", "pos": Vector2(300, 240), "color": Color(1.0, 0.88, 0.45, 0.92)},
	{"id": "feed_critter", "title": "喂鸟", "desc": "撒一把谷粒，麻雀飞来。", "pos": Vector2(980, 700), "color": Color(0.85, 0.65, 0.5, 0.92)},
	{"id": "read_sign", "title": "路牌", "desc": "东市集 · 西农舍 · 北教堂。", "pos": Vector2(520, 200), "color": Color(0.65, 0.7, 0.55, 0.92)},
]

signal interacted(interact_id: String)

var _info: InfoPanel
var _root: Node2D
var _lamp_on: bool = true


static func attach_to(host: Node2D, top_bar: Control = null) -> WorldInteractKit:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as WorldInteractKit
	if existing:
		return existing
	var kit := WorldInteractKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for d in INTERACT_DEFS:
		out.append({"id": d["id"], "title": d["title"], "hint": d["desc"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


func setup(host: Node2D, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "WorldInteractRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	for d in INTERACT_DEFS:
		var interact_id := str(d["id"])
		var title := str(d["title"])
		var desc := str(d["desc"])
		var hs := WorldSpawnUtil.make_hotspot(
			_root,
			title,
			desc,
			d["pos"] as Vector2,
			Vector2(56, 48),
			d["color"] as Color,
		)
		hs.set_meta("interact_id", interact_id)
		hs.activated.connect(func(_h: InteractableHotspot) -> void:
			_handle_interact(interact_id, title, desc)
		)


func live_count() -> int:
	return INTERACT_DEFS.size()


func _handle_interact(interact_id: String, title: String, desc: String) -> void:
	var body := desc
	match interact_id:
		"lamp_toggle":
			_lamp_on = not _lamp_on
			body = "路灯已%s。" % ("点亮" if _lamp_on else "熄灭")
		"shake_tree":
			body = "树叶沙沙作响，一片叶子飘落。"
		"well_water":
			body = "井绳吱呀，打上一桶清凉井水。"
		"feed_critter":
			body = "谷粒刚落地，几只麻雀扑棱飞来。"
		"sit_bench":
			body = "长椅微微晃动，广场闲谈声近了。"
		"crate_search":
			body = "木箱里只有干草与空瓶。"
		"notice_board":
			body = "告示：周末秋收市集，广场张灯。"
		"read_sign":
			body = "路牌：东市集 · 西农舍 · 北教堂。"
	if _info:
		_info.show_info(title, body)
	interacted.emit(interact_id)
