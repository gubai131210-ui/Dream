class_name TrainCarWindowRide
extends Node

## C36 coach: scrolling scenery sits behind the north window wall in *world* space
## (visible through cleared panes). Never draw a HUD postcard on the screen bottom.

const SCENERY := "res://assets/sprites/fx/train_window_scenery_00.png"
const NODE_NAME := "TrainCarWindowRide"
const TILE := 32.0
## Must match InteriorCraft.ORIGIN and c36_train_car window_n / room_w.
const ORIGIN := Vector2i(4, 4)
const ROOM_W := 22
const WINDOW_ANCHOR := Vector2i(11, 1)


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
var _strip_w := 246.0


func _boot() -> void:
	TrainService.notify_player_entered_car(get_parent())
	_world = get_parent().get_node_or_null("InteriorWorld") as Node2D
	if _world == null:
		_world = get_parent().get_node_or_null("World") as Node2D
	call_deferred("_spawn_window_band")
	_spawn_banner()
	_refresh_banner()
	if not TrainService.state_changed.is_connected(_on_state):
		TrainService.state_changed.connect(_on_state)
	_on_state(TrainService.get_active_id(), TrainService.get_state())


func _tile_center(tx: int, ty: int) -> Vector2:
	return Vector2(
		(ORIGIN.x + tx) * TILE + TILE * 0.5,
		(ORIGIN.y + ty) * TILE + TILE * 0.5
	)


func _spawn_window_band() -> void:
	if _world == null or not ResourceLoader.exists(SCENERY):
		push_warning("TrainCarWindowRide: no InteriorWorld or scenery — window view skipped")
		return
	if _band and is_instance_valid(_band):
		_band.queue_free()
	var tex := load(SCENERY) as Texture2D
	if tex == null:
		return
	# Resolve strip width *before* placing either strip so A/B stay seamless.
	_strip_w = maxf(180.0, float(tex.get_width()) * 1.45)

	_band = Node2D.new()
	_band.name = "WindowSceneryBand"
	# InteriorWorld z=2; band absolute z under furniture hotspots (~0+).
	_band.z_index = -8
	_band.z_as_relative = false
	# Center on window_n cluster; nudge north into the pane region of the wall prop.
	var mid := _tile_center(WINDOW_ANCHOR.x, WINDOW_ANCHOR.y)
	_band.position = mid + Vector2(0.0, -22.0)
	_world.add_child(_band)

	_strip_a = _mk_strip(tex, -_strip_w * 0.5)
	_strip_b = _mk_strip(tex, -_strip_w * 0.5 + _strip_w)


func _mk_strip(tex: Texture2D, x0: float) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(1.45, 1.2)
	spr.position = Vector2(x0, 0.0)
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
