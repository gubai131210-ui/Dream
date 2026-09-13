class_name StationTrainRuntime
extends Node2D

## Outdoor train presentation on the station track band.
## Driven by TrainService autoload: approach → dwell → depart → empty steam.
## Motion FX: spinning driving wheels + chimney steam + trailing plume.

const LOCO := "res://assets/sprites/props/train_loco_00.png"
const COACH := "res://assets/sprites/props/train_coach_00.png"
const CONSIST := "res://assets/sprites/props/train_consist_00.png"
const WHEEL := "res://assets/sprites/props/train_wheel_00.png"
const STEAM := "res://assets/sprites/fx/train_steam_00.png"
const STEAM_TRAIL := "res://assets/sprites/fx/train_steam_trail_00.png"
const TOWER := "res://assets/sprites/props/train_water_tower_00.png"
const BOARD := "res://assets/sprites/props/train_timetable_board_00.png"
const BUFFER := "res://assets/sprites/props/train_buffer_00.png"

## Must match StationAssembler track-band mid_y (TRACK_TY0..TY1, tile 32).
## Consist *node* stays on RAIL_Y for YSort; loco sprite is lifted so wheels sit on rails.
const RAIL_Y := 448.0
const DOCK_X := 720.0
const OFF_LEFT := -280.0
const OFF_RIGHT := 1500.0
const CONSIST_SCALE := 1.15
## Flange sit-in below rail mid (px). Keeps wheels visually “in” the rails.
const WHEEL_FLANGE_PX := 6.0
## Local X offsets under loco (consist faces left: stack near left).
const WHEEL_LOCAL_XS := [-78.0, -48.0, -18.0]
## Stack mouth relative to loco body (x left of center; y above loco.position).
const STACK_OFFSET := Vector2(-92.0, -22.0)
## rad/sec when rolling without measurable dx (tween catch-up).
const WHEEL_SPIN_SPEED := 10.0

var _consist: Node2D
var _loco: Sprite2D
var _coach: Sprite2D
var _wheels: Array[Sprite2D] = []
var _stack_steam: CPUParticles2D
var _trail_smoke: CPUParticles2D
var _board_hs: InteractableHotspot
var _ysort: Node2D
var _move_tween: Tween
var _wheels_spinning := false
var _prev_x := 0.0


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
		# Near west map edge now that rails start at tx=0.
		var bh := float(buf.texture.get_height()) * 0.5
		buf.position = Vector2(36, RAIL_Y - (bh - WHEEL_FLANGE_PX))
		buf.z_index = 2
		ysort.add_child(buf)
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
	if ResourceLoader.exists(CONSIST):
		_loco = _mk_sprite(CONSIST, Vector2.ZERO, CONSIST_SCALE)
		_coach = null
		_seat_wheels_on_rails(_loco, CONSIST_SCALE)
	else:
		_loco = _mk_sprite(LOCO, Vector2(-70, 0), 1.1)
		_coach = _mk_sprite(COACH, Vector2(70, 0), 1.1)
		_seat_wheels_on_rails(_loco, 1.1)
		_seat_wheels_on_rails(_coach, 1.1)
	_spawn_driving_wheels()
	_spawn_steam_fx()
	_consist.position = Vector2(OFF_RIGHT, RAIL_Y)
	_prev_x = _consist.position.x


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


func _seat_wheels_on_rails(spr: Sprite2D, scale_f: float) -> void:
	## Lift centered body so wheel line lands on rail mid (node stays at RAIL_Y).
	if spr == null or spr.texture == null:
		return
	var half_h := float(spr.texture.get_height()) * scale_f * 0.5
	spr.position.y = -(half_h - WHEEL_FLANGE_PX)


func _spawn_driving_wheels() -> void:
	_wheels.clear()
	if not ResourceLoader.exists(WHEEL) or _loco == null:
		return
	var tex := load(WHEEL) as Texture2D
	var base_y := _loco.position.y + float(_loco.texture.get_height()) * _loco.scale.y * 0.5 - 10.0
	for i in WHEEL_LOCAL_XS.size():
		var wh := Sprite2D.new()
		wh.name = "DriveWheel_%d" % i
		wh.texture = tex
		wh.centered = true
		wh.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		wh.position = Vector2(WHEEL_LOCAL_XS[i], base_y)
		wh.scale = Vector2(0.95, 0.95)
		wh.z_index = 1
		_consist.add_child(wh)
		_wheels.append(wh)


func _spawn_steam_fx() -> void:
	## Chimney stack: idle chuff when docked, heavy burst when moving.
	var stack_pos := STACK_OFFSET
	if _loco:
		stack_pos = Vector2(STACK_OFFSET.x, _loco.position.y + STACK_OFFSET.y)
	_stack_steam = CPUParticles2D.new()
	_stack_steam.name = "StackSteam"
	_stack_steam.z_index = 6
	_stack_steam.position = stack_pos
	_stack_steam.emitting = false
	_stack_steam.amount = 28
	_stack_steam.lifetime = 1.6
	_stack_steam.preprocess = 0.4
	_stack_steam.explosiveness = 0.05
	_stack_steam.randomness = 0.65
	_stack_steam.local_coords = false
	_stack_steam.direction = Vector2(-0.15, -1.0)
	_stack_steam.spread = 22.0
	_stack_steam.gravity = Vector2(-8.0, -22.0)
	_stack_steam.initial_velocity_min = 18.0
	_stack_steam.initial_velocity_max = 42.0
	_stack_steam.scale_amount_min = 0.35
	_stack_steam.scale_amount_max = 0.95
	_stack_steam.angular_velocity_min = -40.0
	_stack_steam.angular_velocity_max = 40.0
	_configure_steam_texture(_stack_steam, STEAM)
	_consist.add_child(_stack_steam)

	## Trailing plume behind the stack while rolling — thicker, drifts with travel.
	_trail_smoke = CPUParticles2D.new()
	_trail_smoke.name = "TrailSmoke"
	_trail_smoke.z_index = 4
	_trail_smoke.position = stack_pos + Vector2(18.0, 10.0)
	_trail_smoke.emitting = false
	_trail_smoke.amount = 36
	_trail_smoke.lifetime = 2.4
	_trail_smoke.preprocess = 0.2
	_trail_smoke.explosiveness = 0.0
	_trail_smoke.randomness = 0.8
	_trail_smoke.local_coords = false
	_trail_smoke.direction = Vector2(1.0, -0.35)
	_trail_smoke.spread = 28.0
	_trail_smoke.gravity = Vector2(12.0, -10.0)
	_trail_smoke.initial_velocity_min = 10.0
	_trail_smoke.initial_velocity_max = 34.0
	_trail_smoke.scale_amount_min = 0.55
	_trail_smoke.scale_amount_max = 1.35
	_trail_smoke.angular_velocity_min = -25.0
	_trail_smoke.angular_velocity_max = 25.0
	_configure_steam_texture(_trail_smoke, STEAM_TRAIL if ResourceLoader.exists(STEAM_TRAIL) else STEAM)
	_consist.add_child(_trail_smoke)


func _configure_steam_texture(p: CPUParticles2D, path: String) -> void:
	if ResourceLoader.exists(path):
		p.texture = load(path) as Texture2D
	p.color = Color(0.92, 0.94, 0.97, 0.72)
	# Fade out over life.
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
	ramp.colors = PackedColorArray([
		Color(1, 1, 1, 0.15),
		Color(0.95, 0.96, 0.98, 0.75),
		Color(0.85, 0.88, 0.92, 0.0),
	])
	p.color_ramp = ramp


func _set_motion_fx(moving: bool, docked_idle: bool) -> void:
	_wheels_spinning = moving
	if _stack_steam:
		_stack_steam.emitting = moving or docked_idle
		if moving:
			_stack_steam.amount = 36
			_stack_steam.initial_velocity_min = 28.0
			_stack_steam.initial_velocity_max = 58.0
			_stack_steam.scale_amount_max = 1.15
		else:
			_stack_steam.amount = 18
			_stack_steam.initial_velocity_min = 12.0
			_stack_steam.initial_velocity_max = 28.0
			_stack_steam.scale_amount_max = 0.75
	if _trail_smoke:
		_trail_smoke.emitting = moving


func _hide_consist() -> void:
	if _consist:
		_consist.visible = false
		_consist.position = Vector2(OFF_RIGHT, RAIL_Y)
	_set_motion_fx(false, false)


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
			_consist.position = Vector2(OFF_RIGHT, RAIL_Y)
			_prev_x = _consist.position.x
			_set_motion_fx(true, false)
			_move_tween = create_tween()
			_move_tween.tween_property(_consist, "position:x", DOCK_X, TrainService.APPROACH_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_move_tween.finished.connect(func() -> void: _set_motion_fx(false, true), CONNECT_ONE_SHOT)
		TrainService.State.DOCKED:
			_consist.visible = true
			_consist.position = Vector2(DOCK_X, RAIL_Y)
			_set_motion_fx(false, true)
		TrainService.State.DEPARTING:
			_consist.visible = true
			_consist.position = Vector2(DOCK_X, RAIL_Y)
			_prev_x = _consist.position.x
			_set_motion_fx(true, false)
			_move_tween = create_tween()
			_move_tween.tween_property(_consist, "position:x", OFF_LEFT, TrainService.DEPART_ANIM_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			_move_tween.finished.connect(func() -> void: _set_motion_fx(false, false), CONNECT_ONE_SHOT)
		TrainService.State.EN_ROUTE:
			# Depart tween already running (or train left for C36 ride) — do not teleport/restart.
			if _consist and _consist.visible and _consist.position.x > OFF_LEFT + 8.0:
				_set_motion_fx(true, false)
			else:
				_set_motion_fx(false, false)


func _leave_steam_wisps() -> void:
	## After depart: leftover plume hanging over the empty platform.
	if _ysort == null:
		return
	var tex_path := STEAM_TRAIL if ResourceLoader.exists(STEAM_TRAIL) else STEAM
	if not ResourceLoader.exists(tex_path):
		return
	for i in 5:
		var wisp := Sprite2D.new()
		wisp.texture = load(tex_path) as Texture2D
		wisp.centered = true
		wisp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		wisp.position = Vector2(DOCK_X - 20.0 + float(i) * 28.0, RAIL_Y - 70.0 - float(i % 2) * 12.0)
		wisp.modulate = Color(0.9, 0.93, 0.97, 0.5)
		wisp.z_index = 3
		wisp.scale = Vector2(0.8 + 0.12 * float(i), 0.75)
		_ysort.add_child(wisp)
		var tw := wisp.create_tween()
		tw.set_parallel(true)
		tw.tween_property(wisp, "modulate:a", 0.0, 3.2 + float(i) * 0.35)
		tw.tween_property(wisp, "position:y", wisp.position.y - 40.0, 3.2)
		tw.tween_property(wisp, "position:x", wisp.position.x + 50.0, 3.2)
		tw.chain().tween_callback(wisp.queue_free)


func _refresh_board() -> void:
	if _board_hs:
		_board_hs.description = TrainService.timetable_text()


func _process(delta: float) -> void:
	if TrainService.get_state() == TrainService.State.DOCKED:
		_refresh_board()
	if _consist == null or not _consist.visible:
		return
	var dx := _consist.position.x - _prev_x
	_prev_x = _consist.position.x
	if not _wheels_spinning:
		return
	# Prefer measured travel; fall back to constant spin during tweens.
	var spin := (-dx * 0.14) if absf(dx) > 0.02 else (WHEEL_SPIN_SPEED * delta)
	# Always roll “forward” while approaching/departing (x decreases → positive rot).
	if spin < 0.0:
		spin = -spin
	for wh in _wheels:
		if wh:
			wh.rotation += spin
