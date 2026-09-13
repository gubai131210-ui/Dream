class_name FishingSpot
extends InteractableHotspot

## Outdoor fishing hotspot (C18). Click → FishingSession cast→bite→catch.
## Spawned append-only from river / lake assemblers.

const PROMPT := "钓鱼"

var site_id: String = "river"
var spot_id: String = "spot"
var base_title: String = "钓点"
var base_desc: String = "岸边可抛竿的水域。"

var _session: FishingSession = null
var _fx_layer: Node2D
var _bobber: Node2D
var _last_result: Dictionary = {}


static func spawn(parent: Node2D, pos: Vector2, size: Vector2, cfg: Dictionary) -> FishingSpot:
	var hs := FishingSpot.new()
	hs.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	hs.add_child(visual)
	hs.configure(cfg)
	parent.add_child(hs)
	return hs


func configure(cfg: Dictionary) -> void:
	site_id = str(cfg.get("site_id", site_id))
	spot_id = str(cfg.get("spot_id", spot_id))
	base_title = str(cfg.get("title", FishingCatalog.site_label(site_id)))
	base_desc = str(cfg.get("desc", base_desc))
	name = "FishingSpot_%s_%s" % [site_id, spot_id]
	prompt_text = PROMPT
	set_meta("fishing_site", site_id)
	set_meta("fishing_spot", true)
	_ensure_fx()
	_build_marker_visual()
	_refresh_copy()


func _ready() -> void:
	super._ready()
	if not activated.is_connected(_on_activated):
		activated.connect(_on_activated)


func _on_activated(_hs: InteractableHotspot) -> void:
	start_fishing()


func start_fishing() -> void:
	if _session != null and is_instance_valid(_session):
		return
	var host := get_tree().current_scene
	if host == null:
		host = get_parent()
	_session = FishingSession.new()
	_session.name = "FishingSession"
	host.add_child(_session)
	_session.finished.connect(_on_session_finished)
	title = "%s · 钓鱼中" % base_title
	description = "抛竿进行中…咬钩时点「收杆」。"
	_session.begin(self, site_id, FishingCatalog.current_rod_id)


func clear_session() -> void:
	_session = null
	_refresh_copy()


func apply_last_result(result: Dictionary) -> void:
	_last_result = result
	_refresh_copy()


func _on_session_finished(_result: Dictionary) -> void:
	# Keep panel open until user closes; session clears via close button.
	pass


func _refresh_copy() -> void:
	var rod := FishingCatalog.rod_by_id(FishingCatalog.current_rod_id)
	title = base_title
	var lines: PackedStringArray = [
		base_desc,
		"当前竿：%s（会话内可换）" % str(rod.get("name", "?")),
		"流程：抛竿 → 等待 → 咬钩收杆 → 渔获",
	]
	if not _last_result.is_empty():
		if bool(_last_result.get("ok", false)):
			lines.append("上次：钓到【%s】" % str(_last_result.get("fish_name", "?")))
		else:
			lines.append("上次：脱钩跑鱼")
	description = "\n".join(lines)


func _ensure_fx() -> void:
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		visual = Node2D.new()
		visual.name = "Visual"
		add_child(visual)
	_fx_layer = visual.get_node_or_null("Fx") as Node2D
	if _fx_layer == null:
		_fx_layer = Node2D.new()
		_fx_layer.name = "Fx"
		visual.add_child(_fx_layer)
	_bobber = visual.get_node_or_null("Bobber") as Node2D
	if _bobber == null:
		_bobber = Node2D.new()
		_bobber.name = "Bobber"
		visual.add_child(_bobber)


func _build_marker_visual() -> void:
	_ensure_fx()
	for c in _bobber.get_children():
		c.queue_free()
	var icon_path := "res://assets/sprites/fishing/bobber_00.png"
	var tex := WorldSpawnUtil.load_prop_texture(icon_path)
	if tex != null:
		_add_water_ring(_bobber, Vector2(0, 4))
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.position = Vector2(0, -20)
		spr.scale = Vector2(0.9, 0.9)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 3
		_bobber.add_child(spr)
		return
	# Fallback procedural buoy if sprite missing.
	_add_rect(_bobber, Vector2(4, 22), Vector2(-2, -18), Color(0.42, 0.28, 0.14, 0.95), 1)
	_add_rect(_bobber, Vector2(10, 10), Vector2(-5, -28), Color(0.92, 0.35, 0.28, 0.95), 2)
	_add_rect(_bobber, Vector2(10, 4), Vector2(-5, -18), Color(0.95, 0.95, 0.9, 0.9), 2)
	_add_water_ring(_bobber, Vector2(0, 4))


func _add_water_ring(parent: Node2D, pos: Vector2) -> void:
	## Prefer pixel ring; Polygon2D only if FX sprite missing.
	var ring_tex := WorldSpawnUtil.load_prop_texture("res://assets/sprites/fx/fish_ring_00.png")
	if ring_tex != null:
		var spr := Sprite2D.new()
		spr.name = "WaterRing"
		spr.texture = ring_tex
		spr.centered = true
		spr.position = pos
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 0
		parent.add_child(spr)
		return
	var ring := Polygon2D.new()
	ring.name = "WaterRing"
	ring.color = Color(0.45, 0.7, 0.85, 0.35)
	ring.position = pos
	var pts: PackedVector2Array = []
	for i in range(12):
		var a := TAU * float(i) / 12.0
		pts.append(Vector2(cos(a) * 14.0, sin(a) * 14.0 * 0.35))
	ring.polygon = pts
	ring.z_index = 0
	parent.add_child(ring)


func _add_rect(parent: Node2D, size: Vector2, pos: Vector2, color: Color, z: int) -> void:
	var r := ColorRect.new()
	r.size = size
	r.position = pos
	r.color = color
	r.z_index = z
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)


func _clear_fx_temp() -> void:
	if _fx_layer == null:
		return
	for c in _fx_layer.get_children():
		c.queue_free()


func play_cast_fx() -> void:
	_clear_fx_temp()
	_pulse_ring(Color(0.7, 0.85, 1.0, 0.55), 0.5)


func play_wait_fx() -> void:
	_clear_fx_temp()
	# Bubble + ripple + shadow flicker (≥3 C19 cues across session)
	_spawn_bubble(Vector2(-8, -6))
	_spawn_bubble(Vector2(10, -2))
	_pulse_ring(Color(0.55, 0.78, 0.95, 0.45), 1.2)
	_try_water_frame()


func play_bite_fx() -> void:
	_clear_fx_temp()
	_pulse_ring(Color(1.0, 0.85, 0.35, 0.7), 0.35)
	_spawn_splash()


func play_catch_fx(fish: Dictionary) -> void:
	_clear_fx_temp()
	_pulse_ring(Color(0.55, 0.95, 0.55, 0.65), 0.6)
	var path := str(fish.get("sprite", ""))
	if path != "" and ResourceLoader.exists(path):
		var spr := Sprite2D.new()
		spr.texture = load(path) as Texture2D
		spr.position = Vector2(0, -40)
		spr.scale = Vector2(1.1, 1.1)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 5
		_fx_layer.add_child(spr)
		var tw := create_tween()
		tw.tween_property(spr, "position", Vector2(0, -56), 0.45)
		tw.parallel().tween_property(spr, "modulate:a", 0.0, 0.45).set_delay(0.35)


func play_miss_fx() -> void:
	_clear_fx_temp()
	_pulse_ring(Color(0.7, 0.7, 0.75, 0.4), 0.4)


func _pulse_ring(color: Color, duration: float) -> void:
	var splash_tex := WorldSpawnUtil.load_prop_texture("res://assets/sprites/fx/fish_splash_00.png")
	if splash_tex != null:
		var spr := Sprite2D.new()
		spr.texture = splash_tex
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.modulate = color
		spr.position = Vector2(0, 2)
		spr.scale = Vector2(0.7, 0.55)
		_fx_layer.add_child(spr)
		var tw := create_tween()
		tw.tween_property(spr, "scale", Vector2(1.35, 0.9), duration)
		tw.parallel().tween_property(spr, "modulate:a", 0.0, duration)
		tw.tween_callback(spr.queue_free)
		return
	var ring := ColorRect.new()
	ring.size = Vector2(12, 6)
	ring.position = Vector2(-6, 0)
	ring.color = color
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_layer.add_child(ring)
	var tw2 := create_tween()
	tw2.tween_property(ring, "size", Vector2(40, 14), duration)
	tw2.parallel().tween_property(ring, "position", Vector2(-20, -4), duration)
	tw2.parallel().tween_property(ring, "modulate:a", 0.0, duration)
	tw2.tween_callback(ring.queue_free)


func _spawn_bubble(offset: Vector2) -> void:
	var bubble_tex := WorldSpawnUtil.load_prop_texture("res://assets/sprites/fx/fish_bubble_00.png")
	if bubble_tex != null:
		var spr := Sprite2D.new()
		spr.texture = bubble_tex
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = offset + Vector2(2, 2)
		spr.scale = Vector2(0.7, 0.7)
		_fx_layer.add_child(spr)
		var tw := create_tween()
		tw.tween_property(spr, "position", offset + Vector2(0, -18), 0.9)
		tw.parallel().tween_property(spr, "modulate:a", 0.0, 0.9)
		tw.tween_callback(spr.queue_free)
		return
	var b := ColorRect.new()
	b.size = Vector2(5, 5)
	b.position = offset
	b.color = Color(0.75, 0.9, 1.0, 0.7)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_layer.add_child(b)
	var tw2 := create_tween()
	tw2.tween_property(b, "position", offset + Vector2(0, -18), 0.9)
	tw2.parallel().tween_property(b, "modulate:a", 0.0, 0.9)
	tw2.tween_callback(b.queue_free)


func _spawn_splash() -> void:
	## Prefer 4-frame fish_splash sheet; fall back to single _00 sprite tween.
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("oneshot")
	frames.set_animation_loop("oneshot", false)
	frames.set_animation_speed("oneshot", 10.0)
	var n := 0
	for i in range(4):
		var path := "res://assets/sprites/fx/fish_splash_%02d.png" % i
		var tex := WorldSpawnUtil.load_prop_texture(path)
		if tex == null:
			continue
		frames.add_frame("oneshot", tex)
		n += 1
	if n >= 2:
		var anim := AnimatedSprite2D.new()
		anim.name = "FX_fish_splash"
		anim.sprite_frames = frames
		anim.position = Vector2(0, -2)
		anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		anim.z_index = 5
		anim.centered = true
		_fx_layer.add_child(anim)
		anim.play("oneshot")
		anim.animation_finished.connect(func() -> void:
			if is_instance_valid(anim):
				anim.queue_free()
		)
		return
	var splash_tex := WorldSpawnUtil.load_prop_texture("res://assets/sprites/fx/fish_splash_00.png")
	if splash_tex != null:
		var spr := Sprite2D.new()
		spr.texture = splash_tex
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = Vector2(0, -2)
		spr.scale = Vector2(0.85, 0.85)
		_fx_layer.add_child(spr)
		var tw := create_tween()
		tw.tween_property(spr, "position", Vector2(0, -14), 0.35)
		tw.parallel().tween_property(spr, "modulate:a", 0.0, 0.35)
		tw.tween_callback(spr.queue_free)
		return
	for i in 3:
		var drop := ColorRect.new()
		drop.size = Vector2(3, 6)
		drop.position = Vector2(-4 + i * 5, -4)
		drop.color = Color(0.85, 0.95, 1.0, 0.85)
		drop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fx_layer.add_child(drop)
		var tw2 := create_tween()
		tw2.tween_property(drop, "position", drop.position + Vector2(randf_range(-8, 8), -16), 0.35)
		tw2.parallel().tween_property(drop, "modulate:a", 0.0, 0.35)
		tw2.tween_callback(drop.queue_free)


func _try_water_frame() -> void:
	var path := "res://assets/sprites/fx/water_frame_0.png"
	if not ResourceLoader.exists(path):
		return
	var spr := Sprite2D.new()
	spr.texture = load(path) as Texture2D
	spr.position = Vector2(0, 4)
	spr.scale = Vector2(0.7, 0.45)
	spr.modulate = Color(1, 1, 1, 0.55)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fx_layer.add_child(spr)
	var tw := create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, 1.1)
	tw.tween_callback(spr.queue_free)
