class_name MarketStall
extends InteractableHotspot

## C05 same-slot market stall — visual layers swap by state.
## See docs/STALL_C05.md.

enum State { EMPTY, LOCKED, SETUP, OPEN, SOLD_OUT, CLOSED }

const STATE_ORDER: Array[State] = [
	State.EMPTY, State.LOCKED, State.SETUP, State.OPEN, State.SOLD_OUT, State.CLOSED,
]

const STATE_LABEL := {
	State.EMPTY: "空位",
	State.LOCKED: "未解锁",
	State.SETUP: "摆货中",
	State.OPEN: "营业中",
	State.SOLD_OUT: "售罄",
	State.CLOSED: "已收摊",
}

var stall_id: String = "stall"
var base_title: String = "市集摊"
var base_desc: String = ""
var stripe_a: Color = Color(0.85, 0.2, 0.2, 0.92)
var stripe_b: Color = Color(0.95, 0.95, 0.92, 0.92)
var crate_path: String = "res://assets/sprites/props/produce_crate_00.png"
var barrel_path: String = "res://assets/sprites/props/B11-01_barrels_03.png"
var body_path: String = "res://assets/sprites/market/stall_open_wood_00.png"
var state: State = State.OPEN

const DEFAULT_BODY := "res://assets/sprites/market/stall_open_wood_00.png"
const DEFAULT_PRODUCE_CRATE := "res://assets/sprites/props/produce_crate_00.png"
const LOCKED_BOARD := "res://assets/sprites/market/stall_locked_board_00.png"
const EMPTY_MARK := "res://assets/sprites/market/stall_empty_bay_00.png"
const AWNING_TEX := "res://assets/sprites/market/stall_awning_00.png"
const POLE_TEX := "res://assets/sprites/market/stall_pole_00.png"

var _layer: Node2D


static func spawn(parent: Node2D, pos: Vector2, size: Vector2, cfg: Dictionary) -> MarketStall:
	var hs := MarketStall.new()
	hs.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	hs.add_child(visual)
	parent.add_child(hs)
	hs.configure(cfg)
	return hs


func configure(cfg: Dictionary) -> void:
	stall_id = str(cfg.get("id", stall_id))
	base_title = str(cfg.get("title", base_title))
	base_desc = str(cfg.get("desc", base_desc))
	stripe_a = cfg.get("stripe_a", stripe_a)
	stripe_b = cfg.get("stripe_b", stripe_b)
	crate_path = str(cfg.get("crate", crate_path))
	barrel_path = str(cfg.get("barrel", barrel_path))
	body_path = str(cfg.get("body", body_path))
	if body_path.is_empty():
		body_path = DEFAULT_BODY
	var st = cfg.get("state", State.OPEN)
	if typeof(st) == TYPE_STRING:
		state = _parse_state(str(st))
	else:
		state = st as State
	name = "MarketStall_%s" % stall_id
	_ensure_layer()
	apply_state(state)


func cycle_next() -> State:
	var idx := STATE_ORDER.find(state)
	if idx < 0:
		idx = 0
	idx = (idx + 1) % STATE_ORDER.size()
	apply_state(STATE_ORDER[idx])
	return state


func apply_state(next: State) -> void:
	state = next
	_ensure_layer()
	for c in _layer.get_children():
		c.queue_free()
	match state:
		State.EMPTY:
			if not _add_sprite(EMPTY_MARK, Vector2(0, 4), 1.2, Color(1, 1, 1, 0.7)):
				_add_bay_mark()
		State.LOCKED:
			if not _add_sprite(LOCKED_BOARD, Vector2(0, -10), 0.55):
				_add_poles()
				_add_board()
		State.SETUP:
			if not _try_body_sprite(0.48, false, Color(1, 1, 1, 0.75)):
				_add_poles()
				_add_awning(0.55, 4)
			_add_goods(true, false)
		State.OPEN:
			# Body PNG preferred — goods always beside (MARKET_POLISH ≤0.5).
			if not _try_body_sprite(0.55):
				_add_poles()
				_add_awning(1.0, 6)
			_add_goods(true, true)
		State.SOLD_OUT:
			if not _try_body_sprite(0.45, false, Color(0.78, 0.78, 0.82, 1.0)):
				_add_poles()
				_add_awning(0.75, 6, true)
			_add_goods(true, false)
			_add_chip("售罄", Color(0.92, 0.35, 0.28, 0.95))
		State.CLOSED:
			if not _try_body_sprite(0.4, true):
				_add_poles()
				_add_collapsed_awning()
	title = "%s · %s" % [base_title, STATE_LABEL.get(state, "?")]
	description = "%s\n状态：%s（再点切换）" % [base_desc, STATE_LABEL.get(state, "?")]
	set_meta("stall_state", state_name())


func _try_body_sprite(scale_f: float, prefer_drape: bool = false, tint: Color = Color.WHITE) -> bool:
	var path := body_path
	if prefer_drape:
		path = "res://assets/sprites/market/awning_drape_cream_00.png"
	if path.is_empty():
		path = DEFAULT_BODY
	return _add_sprite(path, Vector2(0, -8), scale_f, tint)


func _add_sprite(path: String, pos: Vector2, scale_f: float, tint: Color = Color.WHITE) -> bool:
	var tex := WorldSpawnUtil.load_prop_texture(path)
	if tex == null:
		return false
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.position = pos
	spr.scale = Vector2(scale_f, scale_f)
	spr.modulate = tint
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 2
	_layer.add_child(spr)
	return true


func state_name() -> String:
	match state:
		State.EMPTY:
			return "empty"
		State.LOCKED:
			return "locked"
		State.SETUP:
			return "setup"
		State.OPEN:
			return "open"
		State.SOLD_OUT:
			return "sold_out"
		State.CLOSED:
			return "closed"
	return "open"


func _parse_state(s: String) -> State:
	match s:
		"empty":
			return State.EMPTY
		"locked":
			return State.LOCKED
		"setup":
			return State.SETUP
		"sold_out":
			return State.SOLD_OUT
		"closed":
			return State.CLOSED
		_:
			return State.OPEN


func _ensure_layer() -> void:
	if _layer != null and is_instance_valid(_layer):
		return
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		visual = Node2D.new()
		visual.name = "Visual"
		add_child(visual)
	_layer = visual.get_node_or_null("StallLayers") as Node2D
	if _layer == null:
		_layer = Node2D.new()
		_layer.name = "StallLayers"
		visual.add_child(_layer)


func _rect(parent: Node2D, size: Vector2, pos: Vector2, color: Color, z: int = 0) -> ColorRect:
	var r := ColorRect.new()
	r.size = size
	r.position = pos
	r.color = color
	r.z_index = z
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


func _add_bay_mark() -> void:
	_rect(_layer, Vector2(70, 8), Vector2(-35, 6), Color(0.45, 0.38, 0.28, 0.35), 0)


func _add_poles() -> void:
	if _add_sprite(POLE_TEX, Vector2(-32, -14), 1.0) and _add_sprite(POLE_TEX, Vector2(32, -14), 1.0):
		return
	_rect(_layer, Vector2(3, 30), Vector2(-34, -28), Color(0.35, 0.22, 0.12, 0.92), 1)
	_rect(_layer, Vector2(3, 30), Vector2(31, -28), Color(0.35, 0.22, 0.12, 0.92), 1)


func _add_awning(alpha_mul: float, stripes: int, dull: bool = false) -> void:
	if _add_sprite(AWNING_TEX, Vector2(0, -24), 0.9, Color(1, 1, 1, alpha_mul * (0.75 if dull else 1.0))):
		return
	# Last-resort procedural stripes only if awning PNG missing.
	var awning := Node2D.new()
	awning.name = "Awning"
	awning.position = Vector2(-36, -34)
	_layer.add_child(awning)
	var stripe_w := 12.0
	var h := 20.0
	var a := stripe_a
	var b := stripe_b
	if dull:
		a = a.darkened(0.25)
		b = b.darkened(0.15)
	a.a *= alpha_mul
	b.a *= alpha_mul
	for i in range(stripes):
		_rect(awning, Vector2(stripe_w, h), Vector2(float(i) * stripe_w, 0), a if i % 2 == 0 else b, 2)


func _add_collapsed_awning() -> void:
	if _add_sprite(AWNING_TEX, Vector2(0, -4), 0.85, Color(0.75, 0.75, 0.8, 0.85)):
		return
	_rect(_layer, Vector2(68, 8), Vector2(-34, -6), stripe_a.darkened(0.2), 2)


func _add_board() -> void:
	_rect(_layer, Vector2(56, 36), Vector2(-28, -24), Color(0.42, 0.28, 0.16, 0.95), 2)
	_rect(_layer, Vector2(10, 12), Vector2(-5, -12), Color(0.75, 0.65, 0.25, 0.95), 3)


func _add_chip(text: String, color: Color) -> void:
	var chip := Label.new()
	chip.text = text
	chip.position = Vector2(-18, -48)
	chip.add_theme_color_override("font_color", color)
	chip.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	chip.add_theme_constant_override("shadow_offset_x", 1)
	chip.add_theme_constant_override("shadow_offset_y", 1)
	chip.z_index = 4
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(chip)


func _add_goods(with_crate: bool, with_barrel: bool) -> void:
	# MARKET_POLISH: goods scale ≤0.5, beside/under awning — never in front of face.
	const GOODS_SCALE := 0.48
	if with_crate and ResourceLoader.exists(crate_path):
		var spr := Sprite2D.new()
		spr.texture = load(crate_path) as Texture2D
		spr.position = Vector2(-20, -2)
		spr.scale = Vector2(GOODS_SCALE, GOODS_SCALE)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 3
		_layer.add_child(spr)
	if with_barrel and ResourceLoader.exists(barrel_path):
		var spr2 := Sprite2D.new()
		spr2.texture = load(barrel_path) as Texture2D
		spr2.position = Vector2(22, 0)
		spr2.scale = Vector2(0.45, 0.45)
		spr2.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr2.z_index = 3
		_layer.add_child(spr2)
