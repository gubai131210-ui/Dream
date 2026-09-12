extends Node

## G4 district prop-backed interacts (expanding beyond market / farmland / forest_deep).

const NODE_NAME := "DistrictInteractKit"
const HOST_MARKET := "market"
const HOST_FARMLAND := "farmland"
const HOST_FOREST := "forest_deep"
const HOST_RIVER := "river"
const HOST_LAKE := "lake"
const HOST_STATION := "station"
const HOST_RESIDENTIAL := "residential"

const HOST_DEFS := {
	"market": [
		{
			"id": "mkt_handcart",
			"title": "货板车",
			"desc": "推一把市集货板车，轮子咯吱响。",
			"pos": Vector2(640, 520),
			"sprite": "res://assets/sprites/interior/props/handcart_00.png",
			"scale": 0.5,
			"color": Color(0.72, 0.55, 0.32, 0.92),
		},
		{
			"id": "mkt_crate_stack",
			"title": "果箱堆",
			"desc": "翻看摊侧果箱，闻到熟透果香。",
			"pos": Vector2(1080, 480),
			"sprite": "res://assets/sprites/interior/props/fruit_crate_stack_00.png",
			"scale": 0.5,
			"color": Color(0.85, 0.55, 0.3, 0.92),
		},
	],
	"farmland": [
		{
			"id": "fld_hay_stack",
			"title": "干草垛",
			"desc": "拍打草垛，扬起一缕尘草。",
			"pos": Vector2(880, 520),
			"sprite": "res://assets/sprites/interior/props/hay_stack_00.png",
			"scale": 0.5,
			"color": Color(0.9, 0.78, 0.35, 0.92),
		},
		{
			"id": "fld_trough",
			"title": "饮水槽",
			"desc": "检查槽里清水，牲畜脚印还湿着。",
			"pos": Vector2(1000, 640),
			"sprite": "res://assets/sprites/interior/props/trough_00.png",
			"scale": 0.5,
			"color": Color(0.45, 0.65, 0.85, 0.92),
		},
	],
	"forest_deep": [
		{
			"id": "fdeep_wood_pile",
			"title": "枯枝堆",
			"desc": "拨开枯枝，听林间鸟雀惊飞。",
			"pos": Vector2(480, 520),
			"sprite": "res://assets/sprites/interior/props/wood_pile_00.png",
			"scale": 0.5,
			"color": Color(0.45, 0.35, 0.25, 0.92),
		},
		{
			"id": "fdeep_moss_rock",
			"title": "苔石",
			"desc": "抚摸苔石，凉意沁入指尖。",
			"pos": Vector2(360, 640),
			"sprite": "res://assets/sprites/props/rock_03.png",
			"scale": 0.55,
			"color": Color(0.4, 0.55, 0.4, 0.92),
		},
	],
	"river": [
		{
			"id": "riv_barrel",
			"title": "河岸木桶",
			"desc": "敲敲木桶，听回声测水位。",
			"pos": Vector2(420, 700),
			"sprite": "res://assets/sprites/props/barrel_1.png",
			"scale": 0.5,
			"color": Color(0.55, 0.45, 0.3, 0.92),
		},
		{
			"id": "riv_sack",
			"title": "晒网袋",
			"desc": "抖一抖岸边网袋，沙粒簌簌落下。",
			"pos": Vector2(900, 680),
			"sprite": "res://assets/sprites/props/sack_0.png",
			"scale": 0.5,
			"color": Color(0.7, 0.65, 0.4, 0.92),
		},
	],
	"lake": [
		{
			"id": "lake_dock_barrel",
			"title": "系缆桶",
			"desc": "检查系缆空桶，绳结还沾着水。",
			"pos": Vector2(960, 500),
			"sprite": "res://assets/sprites/props/barrel_1.png",
			"scale": 0.5,
			"color": Color(0.5, 0.55, 0.7, 0.92),
		},
		{
			"id": "lake_bench",
			"title": "湖畔长凳",
			"desc": "坐一会儿看湖面粼光。",
			"pos": Vector2(720, 700),
			"sprite": "res://assets/sprites/props/bench_0.png",
			"scale": 0.55,
			"color": Color(0.65, 0.55, 0.35, 0.92),
		},
	],
	"station": [
		{
			"id": "stn_crate",
			"title": "站台货箱",
			"desc": "掀开货箱盖，闻到机油味。",
			"pos": Vector2(720, 560),
			"sprite": "res://assets/sprites/props/crate_0.png",
			"scale": 0.5,
			"color": Color(0.6, 0.5, 0.35, 0.92),
		},
		{
			"id": "stn_lamp",
			"title": "月台灯",
			"desc": "拨一下灯罩，铜环叮一声。",
			"pos": Vector2(520, 480),
			"sprite": "res://assets/sprites/props/lamp_0.png",
			"scale": 0.55,
			"color": Color(0.9, 0.75, 0.35, 0.92),
		},
	],
	"residential": [
		{
			"id": "res_bench",
			"title": "巷口木凳",
			"desc": "在巷口木凳歇脚，听见邻里闲话。",
			"pos": Vector2(560, 560),
			"sprite": "res://assets/sprites/props/bench_0.png",
			"scale": 0.55,
			"color": Color(0.7, 0.6, 0.4, 0.92),
		},
		{
			"id": "res_sack",
			"title": "门廊粮袋",
			"desc": "拍拍门廊粮袋，谷壳飞起。",
			"pos": Vector2(880, 520),
			"sprite": "res://assets/sprites/props/sack_0.png",
			"scale": 0.5,
			"color": Color(0.75, 0.68, 0.4, 0.92),
		},
	],
}

signal interacted(interact_id: String)

var _info: InfoPanel
var _root: Node2D


static func attach_to(host: Node2D, host_id: String, top_bar: Control = null) -> Node:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME)
	if existing:
		return existing
	var kit = load("res://scripts/world/district_interact_kit.gd").new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, host_id, top_bar)
	return kit


func setup(host: Node2D, host_id: String, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "DistrictInteractRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	var defs: Array = HOST_DEFS.get(host_id, [])
	for d in defs:
		var interact_id := str(d["id"])
		var title := str(d["title"])
		var desc := str(d["desc"])
		var col: Color = d.get("color", Color(0.85, 0.75, 0.35, 0.9))
		var hs := WorldSpawnUtil.make_hotspot(
			_root,
			title,
			desc,
			d["pos"] as Vector2,
			Vector2(56, 48),
			col,
			str(d.get("sprite", "")),
			float(d.get("scale", 0.55)),
		)
		hs.set_meta("interact_id", interact_id)
		hs.activated.connect(func(_h: InteractableHotspot) -> void:
			_on_interact(interact_id, title, desc, _h)
		)


func live_count() -> int:
	if _root == null:
		return 0
	return _root.get_child_count()


func _on_interact(interact_id: String, title: String, desc: String, hs: InteractableHotspot) -> void:
	if hs:
		var visual := hs.get_node_or_null("Visual") as CanvasItem
		if visual:
			var tw := visual.create_tween()
			tw.tween_property(visual, "modulate", Color(1.25, 1.2, 0.9), 0.08)
			tw.tween_property(visual, "modulate", Color.WHITE, 0.18)
	if _info:
		_info.show_info(title, desc)
	interacted.emit(interact_id)
