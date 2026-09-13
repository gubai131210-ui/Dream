class_name FarmCropKit
extends Node

## Phase0 turnip plots on farmland — plant / water / morning grow / harvest → Inventory.

const NODE_NAME := "FarmCropKit"
const STAGE_PATHS := [
	"res://assets/sprites/props/crop_turnip_stage_00.png",
	"res://assets/sprites/props/crop_turnip_stage_01.png",
	"res://assets/sprites/props/crop_turnip_stage_02.png",
	"res://assets/sprites/props/crop_turnip_stage_03.png",
]
const SEED_ID := "seed_turnip"
const CROP_ID := "crop_turnip"
const WATER_SPLASH := "res://assets/sprites/fx/crop_water_splash_00.png"
const HARVEST_FX := "res://assets/sprites/fx/crop_harvest_spark_00.png"

## Local plot positions on farmland (dirt bed NW corner cluster).
const PLOT_LOCALS := [
	Vector2(360, 360),
	Vector2(400, 360),
	Vector2(440, 360),
	Vector2(480, 360),
]


static func attach_to(host: Node2D, ysort: Node2D, info: Node = null) -> FarmCropKit:
	if host == null or ysort == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as FarmCropKit
	if existing:
		return existing
	var kit := FarmCropKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit._boot(ysort, info)
	return kit


var _ysort: Node2D
var _info: Node
var _plots: Array = []  # Dictionary each
var _prev_time: int = -1


func _boot(ysort: Node2D, info: Node) -> void:
	_ysort = ysort
	_info = info
	InventoryService.grant_starter_seeds_if_empty()
	for i in PLOT_LOCALS.size():
		_spawn_plot(i, PLOT_LOCALS[i])
	var dnw := _find_day_night()
	if dnw and dnw.has_signal("state_changed") and not dnw.state_changed.is_connected(_on_env):
		dnw.state_changed.connect(_on_env)
		_prev_time = int(dnw.get("time_grade")) if dnw.get("time_grade") != null else 0


func _find_day_night() -> Node:
	var host := get_parent()
	if host == null:
		return null
	return host.get_node_or_null("DayNightWeather")


func _spawn_plot(idx: int, local: Vector2) -> void:
	var hs := InteractableHotspot.new()
	hs.name = "CropPlot_%d" % idx
	hs.title = "试验畦"
	hs.description = "空畦：可播种芜菁。"
	hs.position = local
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(36, 28)
	shape.shape = rect
	hs.add_child(shape)
	var vis := Node2D.new()
	vis.name = "Visual"
	hs.add_child(vis)
	var spr := Sprite2D.new()
	spr.name = "CropSprite"
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(0, -8)
	vis.add_child(spr)
	hs.activated.connect(_on_plot_activated.bind(idx))
	_ysort.add_child(hs)
	_plots.append({
		"hs": hs,
		"spr": spr,
		"stage": -1,  # -1 empty, 0..3 growing/ripe
		"watered": false,
		"days_in_stage": 0,
	})
	_refresh_plot(idx)


func _on_plot_activated(_hotspot: InteractableHotspot, idx: int) -> void:
	if idx < 0 or idx >= _plots.size():
		return
	var p: Dictionary = _plots[idx]
	var stage: int = int(p["stage"])
	if stage < 0:
		var buy: Dictionary = InventoryService.try_remove(SEED_ID, 1)
		if not bool(buy.get("ok", false)):
			_toast("播种", "需要芜菁种子（已自动发放可再进田试试）。")
			InventoryService.grant_starter_seeds_if_empty()
			return
		p["stage"] = 0
		p["watered"] = false
		p["days_in_stage"] = 0
		_plots[idx] = p
		_refresh_plot(idx)
		_toast("播种", "种下了芜菁苗。记得浇水，等天亮生长。")
		return
	if stage >= 3:
		var add: Dictionary = InventoryService.try_add(CROP_ID, 1)
		_toast("收获", str(add.get("msg", "")))
		if bool(add.get("ok", false)):
			p["stage"] = -1
			p["watered"] = false
			p["days_in_stage"] = 0
			_plots[idx] = p
			_refresh_plot(idx)
			_play_harvest_fx(p["hs"] as Node2D)
		return
	# Water
	if bool(p["watered"]):
		_toast("浇水", "这畦今天已经浇过了，等天亮再看。")
		return
	p["watered"] = true
	_plots[idx] = p
	_refresh_plot(idx)
	_play_water_fx(p["hs"] as Node2D)
	_toast("浇水", "浇好了。明天早晨会生长（或点 TopBar 日夜切换到白天）。")


func _on_env(time_grade: int, weather: int) -> void:
	# Morning tick: Night → Day
	const NIGHT := 1
	const DAY := 0
	if _prev_time == NIGHT and time_grade == DAY:
		_morning_tick(weather)
	_prev_time = time_grade


func _morning_tick(weather: int) -> void:
	const RAIN := 1  # match DayNightWeather.WeatherKind if differs — soft
	for i in _plots.size():
		var p: Dictionary = _plots[i]
		var stage: int = int(p["stage"])
		if stage < 0 or stage >= 3:
			continue
		var wet := bool(p["watered"]) or weather == RAIN
		p["watered"] = false
		if wet:
			p["days_in_stage"] = int(p["days_in_stage"]) + 1
			if int(p["days_in_stage"]) >= 1:
				p["stage"] = mini(3, stage + 1)
				p["days_in_stage"] = 0
		_plots[i] = p
		_refresh_plot(i)


func _refresh_plot(idx: int) -> void:
	var p: Dictionary = _plots[idx]
	var hs: InteractableHotspot = p["hs"]
	var spr: Sprite2D = p["spr"]
	var stage: int = int(p["stage"])
	if stage < 0:
		spr.texture = null
		hs.title = "试验畦"
		hs.description = "空畦。点一下播种（消耗芜菁种子）。种子不足时会自动补发试用种子。"
		return
	var path := STAGE_PATHS[clampi(stage, 0, STAGE_PATHS.size() - 1)]
	if ResourceLoader.exists(path):
		spr.texture = load(path) as Texture2D
	spr.modulate = Color(0.75, 0.85, 1.0, 1.0) if bool(p["watered"]) else Color.WHITE
	if stage >= 3:
		hs.title = "成熟芜菁"
		hs.description = "点一下收获，芜菁进入背包。"
	else:
		hs.title = "芜菁苗 · 第%d阶" % (stage + 1)
		hs.description = ("已浇水，等天亮。" if bool(p["watered"]) else "需要浇水。点一下浇水。")


func _play_water_fx(at: Node2D) -> void:
	if at == null or not ResourceLoader.exists(WATER_SPLASH):
		return
	var fx := Sprite2D.new()
	fx.texture = load(WATER_SPLASH) as Texture2D
	fx.centered = true
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fx.global_position = at.global_position + Vector2(0, -12)
	fx.z_index = 20
	_ysort.add_child(fx)
	var tw := fx.create_tween()
	tw.tween_property(fx, "modulate:a", 0.0, 0.45)
	tw.tween_callback(fx.queue_free)


func _play_harvest_fx(at: Node2D) -> void:
	if at == null or not ResourceLoader.exists(HARVEST_FX):
		return
	var fx := Sprite2D.new()
	fx.texture = load(HARVEST_FX) as Texture2D
	fx.centered = true
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fx.global_position = at.global_position + Vector2(0, -16)
	fx.z_index = 20
	_ysort.add_child(fx)
	var tw := fx.create_tween()
	tw.tween_property(fx, "position:y", fx.position.y - 12.0, 0.5)
	tw.parallel().tween_property(fx, "modulate:a", 0.0, 0.5)
	tw.tween_callback(fx.queue_free)


func _toast(title: String, body: String) -> void:
	if _info and _info.has_method("show_info"):
		_info.call("show_info", title, body)
