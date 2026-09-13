class_name StationTrainRuntime
extends Node2D

## Outdoor train presentation on the station track band.
## Driven by TrainService autoload: approach → dwell → depart → empty steam.

const LOCO := "res://assets/sprites/props/train_loco_00.png"
const COACH := "res://assets/sprites/props/train_coach_00.png"
const CONSIST := "res://assets/sprites/props/train_consist_00.png"
const STEAM := "res://assets/sprites/fx/train_steam_00.png"
const TOWER := "res://assets/sprites/props/train_water_tower_00.png"
const BOARD := "res://assets/sprites/props/train_timetable_board_00.png"
const BUFFER := "res://assets/sprites/props/train_buffer_00.png"

## Align with StationAssembler track band mid (TRACK_TY0..TY1, tile 32 → y=448).
const TRACK_Y := 448.0
const DOCK_X := 720.0
const OFF_LEFT := -220.0
const OFF_RIGHT := 1500.0

var _consist: Node2D
var _loco: Sprite2D
var _coach: Sprite2D
var _steam: Sprite2D
var _board_hs: InteractableHotspot
var _ysort: Node2D
var _move_tween: Tween


static func attach_to(host: Node2D, ysort: Node2D) -> StationTrainRuntime:
	if host == null or ysort == null:
		return null
	var existing := host.get_node_or_null("StationTrainRuntime") as StationTrainRuntime
	if existing:
		return existing
	var rt := StationTrainRuntime.new()
	rt.name = "StationTrainRuntime"
	host.add_child(rt)
	rt.setup(ysort)
	return rt


func setup(ysort: Node2D) -> void:
	_ysort = ysort
	_spawn_scenery(ysort)
	_spawn_consist(ysort)
	_hide_consist()
	if not TrainService.state_changed.is_connected(_on_state):
		TrainService.state_changed.connect(_on_state)
	_on_state(TrainService.get_active_id(), TrainService.get_state())
	_refresh_board()


func _spawn_scenery(ysort: Node2D) -> void:
	if ResourceLoader.exists(TOWER):
		var tower := Sprite2D.new()
		tower.name = "WaterTower"
		tower.texture = load(TOWER) as Texture2D
		tower.centered = true
		tower.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tower.position = Vector2(1080, 390)
		tower.z_index = 2
		tower.scale = Vector2(1.05, 1.05)
		ysort.add_child(tower)
	if ResourceLoader.exists(BUFFER):
		var buf := Sprite2D.new()
		buf.texture = load(BUFFER) as Texture2D
		buf.centered = true
		buf.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		buf.position = Vector2(180, TRACK_Y)
		buf.z_index = 2
		ysort.add_child(buf)
	# Timetable board hotspot — live text from TrainService.
	_board_hs = InteractableHotspot.new()
	_board_hs.name = "行车牌"
	_board_hs.title = "行车牌"
	_board_hs.description = TrainService.timetable_text()
	_board_hs.position = Vector2(520, 340)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(72, 64)
	shape.shape = rect
	_board_hs.add_child(shape)
	var vis := Node2D.new()
	vis.name = "Visual"
	_board_hs.add_child(vis)
	if ResourceLoader.exists(BOARD):
		var spr := Sprite2D.new()
		spr.texture = load(BOARD) as Texture2D
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.scale = Vector2(1.1, 1.1)
		vis.add_child(spr)
	ysort.add_child(_board_hs)


func _spawn_consist(ysort: Node2D) -> void:
	_consist = Node2D.new()
	_consist.name = "TrainConsist"
	_consist.z_index = 5
	ysort.add_child(_consist)
	# Prefer full A11-matched loco+coach silhouette; fall back to split sprites.
	if ResourceLoader.exists(CONSIST):
		_loco = _mk_sprite(CONSIST, Vector2.ZERO, 1.15)
		_coach = null
		_steam = _mk_sprite(STEAM, Vector2(-100, -52), 0.95)
	else:
		_loco = _mk_sprite(LOCO, Vector2(-70, 0), 1.1)
		_coach = _mk_sprite(COACH, Vector2(70, 0), 1.1)
		_steam = _mk_sprite(STEAM, Vector2(-95, -48), 0.9)
	if _steam:
		_steam.modulate.a = 0.75
		var tw := _steam.create_tween().set_loops()
		tw.tween_property(_steam, "modulate:a", 0.35, 0.55)
		tw.tween_property(_steam, "modulate:a", 0.85, 0.7)
	_consist.position = Vector2(OFF_RIGHT, TRACK_Y)


func _mk_sprite(path: String, local: Vector2, scale_f: float) -> Sprite2D:
	if not ResourceLoader.exists(path):
		return null
	var spr := Sprite2D.new()
	spr.texture = load(path) as Texture2D
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = local
	spr.scale = Vector2(scale_f, scale_f)
	_consist.add_child(spr)
	return spr


func _hide_consist() -> void:
	if _consist:
		_consist.visible = false
		_consist.position = Vector2(OFF_RIGHT, TRACK_Y)


func _on_state(_sid: String, state: int) -> void:
	_refresh_board()
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()
	match state:
		TrainService.State.ABSENT:
			_leave_steam_wisps()
			_hide_consist()
		TrainService.State.APPROACHING:
			_consist.visible = true
			_consist.position = Vector2(OFF_RIGHT, TRACK_Y)
			_move_tween = create_tween()
			_move_tween.tween_property(_consist, "position:x", DOCK_X, TrainService.APPROACH_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		TrainService.State.DOCKED:
			_consist.visible = true
			_consist.position = Vector2(DOCK_X, TRACK_Y)
		TrainService.State.DEPARTING, TrainService.State.EN_ROUTE:
			_consist.visible = true
			_consist.position = Vector2(DOCK_X, TRACK_Y)
			_move_tween = create_tween()
			_move_tween.tween_property(_consist, "position:x", OFF_LEFT, TrainService.DEPART_ANIM_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _leave_steam_wisps() -> void:
	## After depart: empty platform still “remembers” the train for a few seconds.
	if not ResourceLoader.exists(STEAM) or _ysort == null:
		return
	for i in 3:
		var wisp := Sprite2D.new()
		wisp.texture = load(STEAM) as Texture2D
		wisp.centered = true
		wisp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		wisp.position = Vector2(DOCK_X - 40.0 + float(i) * 36.0, TRACK_Y - 30.0)
		wisp.modulate = Color(0.9, 0.95, 1.0, 0.55)
		wisp.z_index = 3
		wisp.scale = Vector2(0.7 + 0.1 * float(i), 0.7)
		_ysort.add_child(wisp)
		var tw := wisp.create_tween()
		tw.tween_property(wisp, "modulate:a", 0.0, 2.8 + float(i) * 0.4)
		tw.tween_callback(wisp.queue_free)


func _refresh_board() -> void:
	if _board_hs:
		_board_hs.description = TrainService.timetable_text()


func _process(_delta: float) -> void:
	# Keep board text fresh during dwell countdown.
	if TrainService.get_state() == TrainService.State.DOCKED:
		_refresh_board()
