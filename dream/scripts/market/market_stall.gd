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
	_play_cycle_fx()
	return state


func mcp_cycle() -> Dictionary:
	## Sync probe: advance stall state once and report FX.
	var before := state_name()
	cycle_next()
	var fx_name := ""
	var fx_playing := false
	var fx_frames := 0
	var visual := get_node_or_null("Visual") as Node
	if visual:
		for c in visual.get_children():
			if c is AnimatedSprite2D and str(c.name).begins_with("FX_"):
				var anim := c as AnimatedSprite2D
				fx_name = str(anim.name)
				fx_playing = anim.is_playing()
				var sf := anim.sprite_frames
				if sf != null and sf.has_animation("oneshot"):
					fx_frames = sf.get_frame_count("oneshot")
				break
	return {
		"ok": true,
		"stall_id": stall_id,
		"from": before,
		"to": state_name(),
		"fx": fx_name,
		"fx_playing": fx_playing,
		"fx_frames": fx_frames,
	}


func _play_cycle_fx() -> void:
	## Short multi-frame tap feedback when cycling stall states (C05).
	var dir := "res://assets/sprites/fx"
	var prefix := "board_rustle"
	var local := Vector2(0, -22)
	var fps := 10.0
	match state:
		State.OPEN, State.SETUP, State.SOLD_OUT:
			dir = "res://assets/sprites/props"
			prefix = "crate_lid"
			local = Vector2(10, -14)
			fps = 8.0
		State.CLOSED:
			dir = "res://assets/sprites/fx"
			prefix = "leaf_fall"
			local = Vector2(0, -12)
			fps = 12.0
		_:
			pass
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	var prior := visual.get_node_or_null("FX_%s" % prefix)
	if prior != null:
		prior.free()
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("oneshot")
	frames.set_animation_loop("oneshot", false)
	frames.set_animation_speed("oneshot", fps)
	var n := 0
	for i in range(4):
		var path := "%s/%s_%02d.png" % [dir, prefix, i]
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
		if tex == null:
			var abs_path := ProjectSettings.globalize_path(path)
			if FileAccess.file_exists(abs_path):
				var img := Image.load_from_file(abs_path)
				if img != null:
					tex = ImageTexture.create_from_image(img)
		if tex == null:
			continue
		frames.add_frame("oneshot", tex)
		n += 1
	if n == 0:
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "FX_%s" % prefix
	anim.sprite_frames = frames
	anim.position = local
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 10
	anim.centered = true
	visual.add_child(anim)
	anim.play("oneshot")
	anim.animation_finished.connect(func() -> void:
		if not is_instance_valid(anim):
			return
		anim.pause()
		var sf2 := anim.sprite_frames
		if sf2 != null and sf2.has_animation("oneshot"):
			var last := sf2.get_frame_count("oneshot") - 1
			if last >= 0:
				anim.frame = last
	)


func apply_state(next: State) -> void:
	state = next
	_ensure_layer()
	for c in _layer.get_children():
		c.queue_free()
	match state:
		State.EMPTY:
			if not _add_sprite(EMPTY_MARK, Vector2(0, 4), 1.2, Color(1, 1, 1, 0.7)):
				push_error("MarketStall: missing stall_empty_bay_00 (ColorRect bay forbidden)")
		State.LOCKED:
			if not _add_sprite(LOCKED_BOARD, Vector2(0, -10), 0.55):
				push_error("MarketStall: missing stall_locked_board_00 (ColorRect board forbidden)")
		State.SETUP:
			if not _try_body_sprite(0.48, false, Color(1, 1, 1, 0.75)):
				if not (_add_poles() and _add_awning(0.55)):
					push_error("MarketStall: SETUP missing body/awning/pole sprites")
			_add_goods(true, false)
		State.OPEN:
			# Body PNG preferred — goods always beside (MARKET_POLISH ≤0.5).
			if not _try_body_sprite(0.55):
				if not (_add_poles() and _add_awning(1.0)):
					push_error("MarketStall: OPEN missing body/awning/pole sprites")
			_add_goods(true, true)
		State.SOLD_OUT:
			if not _try_body_sprite(0.45, false, Color(0.78, 0.78, 0.82, 1.0)):
				if not (_add_poles() and _add_awning(0.75, true)):
					push_error("MarketStall: SOLD_OUT missing body/awning/pole sprites")
			_add_goods(true, false)
			_add_chip("售罄", Color(0.92, 0.35, 0.28, 0.95))
		State.CLOSED:
			if not _try_body_sprite(0.4, true):
				if not (_add_poles() and _add_collapsed_awning()):
					push_error("MarketStall: CLOSED missing body/awning/pole sprites")
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


func _add_poles() -> bool:
	var ok_l := _add_sprite(POLE_TEX, Vector2(-32, -14), 1.0)
	var ok_r := _add_sprite(POLE_TEX, Vector2(32, -14), 1.0)
	if ok_l and ok_r:
		return true
	push_error("MarketStall: missing stall_pole_00 (ColorRect poles forbidden)")
	return false


func _add_awning(alpha_mul: float, dull: bool = false) -> bool:
	if _add_sprite(AWNING_TEX, Vector2(0, -24), 0.9, Color(1, 1, 1, alpha_mul * (0.75 if dull else 1.0))):
		return true
	push_error("MarketStall: missing stall_awning_00 (ColorRect stripes forbidden)")
	return false


func _add_collapsed_awning() -> bool:
	if _add_sprite(AWNING_TEX, Vector2(0, -4), 0.85, Color(0.75, 0.75, 0.8, 0.85)):
		return true
	push_error("MarketStall: missing stall_awning_00 for collapsed state")
	return false


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
