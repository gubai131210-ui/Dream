class_name TrainCarWindowRide
extends Node

## Mount inside C36 train car: parallax window scenery while EN_ROUTE / DEPARTING.

const SCENERY := "res://assets/sprites/fx/train_window_scenery_00.png"
const NODE_NAME := "TrainCarWindowRide"


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


var _layer: CanvasLayer
var _strip_a: Sprite2D
var _strip_b: Sprite2D
var _banner: Label
var _scrolling := false


func _boot() -> void:
	TrainService.notify_player_entered_car(get_parent())
	_layer = CanvasLayer.new()
	_layer.name = "WindowSceneryLayer"
	_layer.layer = 8
	add_child(_layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(root)
	if ResourceLoader.exists(SCENERY):
		_strip_a = _mk_strip(root, 0.0)
		_strip_b = _mk_strip(root, 220.0)
	_banner = Label.new()
	_banner.position = Vector2(36, 24)
	_banner.add_theme_font_size_override("font_size", 16)
	_banner.modulate = Color(0.95, 0.96, 0.9, 1.0)
	root.add_child(_banner)
	_refresh_banner()
	if not TrainService.state_changed.is_connected(_on_state):
		TrainService.state_changed.connect(_on_state)
	_on_state(TrainService.get_active_id(), TrainService.get_state())


func _mk_strip(parent: Control, x0: float) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = load(SCENERY) as Texture2D
	spr.centered = false
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(x0, 520)
	spr.scale = Vector2(2.4, 1.6)
	spr.modulate = Color(0.85, 0.9, 0.95, 0.9)
	parent.add_child(spr)
	return spr


func _on_state(_sid: String, state: int) -> void:
	_refresh_banner()
	_scrolling = state == TrainService.State.DEPARTING or state == TrainService.State.EN_ROUTE
	if state == TrainService.State.DOCKED and TrainService.has_ticket_for_active():
		# Soft auto-depart soon after boarding so ride is discoverable.
		if TrainService.get_state() == TrainService.State.DOCKED:
			pass


func _refresh_banner() -> void:
	var s := TrainService.get_active_service()
	var title := str(s.get("title", "火车"))
	match TrainService.get_state():
		TrainService.State.DOCKED:
			_banner.text = "%s · 停靠中 — 看窗外或等发车" % title
		TrainService.State.DEPARTING:
			_banner.text = "%s · 正在离站…" % title
		TrainService.State.EN_ROUTE:
			_banner.text = "%s · 窗外景色掠过 → %s" % [title, str(s.get("dest_title", ""))]
		_:
			_banner.text = TrainService.board_hint()


func _process(delta: float) -> void:
	if not _scrolling:
		return
	var speed := 140.0 if TrainService.get_state() == TrainService.State.EN_ROUTE else 70.0
	for spr in [_strip_a, _strip_b]:
		if spr == null:
			continue
		spr.position.x -= speed * delta
		if spr.position.x < -240.0:
			spr.position.x += 440.0
