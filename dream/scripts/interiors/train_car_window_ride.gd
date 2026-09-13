class_name TrainCarWindowRide
extends Node

## C36 coach: scrolling scenery sits behind the north window wall in *world* space
## (visible through cleared panes). Never draw a HUD postcard on the screen bottom.

const SCENERY := "res://assets/sprites/fx/train_window_scenery_00.png"
const NODE_NAME := "TrainCarWindowRide"
const TILE := 32.0
## Align with c36_train_car room_w / window_n cluster.
const ROOM_W := 22
const BAND_Y := 28.0


static func attach_to(host: Node) -> TrainCarWindowRide:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as TrainCarWindowRide
	if existing:
		return existing
	var ride := TrainCarWindowRide.new()
	ride.name = NODE_NAME
	host.add_child(ride)
	ride._boot()
	return ride


var _world: Node2D
var _band: Node2D
var _strip_a: Sprite2D
var _strip_b: Sprite2D
var _banner: Label
var _scrolling := false
var _strip_w := 220.0


func _boot() -> void:
	TrainService.notify_player_entered_car(get_parent())
	_world = get_parent().get_node_or_null("World") as Node2D
	if _world == null:
		_world = get_parent() as Node2D
	# Defer one frame so furniture (window walls) exists and we sit behind them.
	call_deferred("_spawn_window_band")
	_spawn_banner()
	_refresh_banner()
	if not TrainService.state_changed.is_connected(_on_state):
		TrainService.state_changed.connect(_on_state)
	_on_state(TrainService.get_active_id(), TrainService.get_state())


func _spawn_window_band() -> void:
	if _world == null or not ResourceLoader.exists(SCENERY):
		return
	if _band and is_instance_valid(_band):
		_band.queue_free()
	_band = Node2D.new()
	_band.name = "WindowSceneryBand"
	# Behind walls/props (foundation -20, props ~0+); still above floor foundation.
	_band.z_index = -8
	_band.z_as_relative = false
	# Center under the three window-wall segments (anchor ~tx 11).
	_band.position = Vector2(float(ROOM_W) * TILE * 0.5, BAND_Y)
	_world.add_child(_band)
	_strip_a = _mk_strip(-_strip_w * 0.5)
	_strip_b = _mk_strip(-_strip_w * 0.5 + _strip_w)


func _mk_strip(x0: float) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = load(SCENERY) as Texture2D
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if spr.texture:
		_strip_w = maxf(180.0, float(spr.texture.get_width()) * 1.45)
	# Wide enough to fill several window panes across the coach.
	spr.scale = Vector2(1.45, 1.2)
	spr.position = Vector2(x0, 8.0)
	spr.modulate = Color(0.95, 0.9, 0.8, 1.0)
	_band.add_child(spr)
	return spr


func _spawn_banner() -> void:
	var layer := CanvasLayer.new()
	layer.name = "RideBannerLayer"
	layer.layer = 12
	add_child(layer)
	_banner = Label.new()
	_banner.position = Vector2(36, 56)
	_banner.add_theme_font_size_override("font_size", 15)
	_banner.modulate = Color(0.95, 0.93, 0.86, 1.0)
	layer.add_child(_banner)


func _on_state(_sid: String, state: int) -> void:
	_refresh_banner()
	# Docked: gentle creep; depart/en-route: faster scroll.
	_scrolling = (
		state == TrainService.State.DOCKED
		or state == TrainService.State.DEPARTING
		or state == TrainService.State.EN_ROUTE
	)


func _refresh_banner() -> void:
	if _banner == null:
		return
	var s := TrainService.get_active_service()
	var title := str(s.get("title", "火车"))
	match TrainService.get_state():
		TrainService.State.DOCKED:
			_banner.text = "%s · 停靠中 — 透过北窗看站外" % title
		TrainService.State.DEPARTING:
			_banner.text = "%s · 正在离站…" % title
		TrainService.State.EN_ROUTE:
			_banner.text = "%s · 窗外景色掠过 → %s" % [title, str(s.get("dest_title", ""))]
		_:
			_banner.text = TrainService.board_hint()


func _process(delta: float) -> void:
	if not _scrolling or _band == null:
		return
	var st := TrainService.get_state()
	var speed := 14.0
	if st == TrainService.State.DEPARTING:
		speed = 75.0
	elif st == TrainService.State.EN_ROUTE:
		speed = 135.0
	for spr in [_strip_a, _strip_b]:
		if spr == null:
			continue
		spr.position.x -= speed * delta
		if spr.position.x < -_strip_w:
			spr.position.x += _strip_w * 2.0
