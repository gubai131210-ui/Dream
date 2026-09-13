class_name FishCage
extends InteractableHotspot

## C22 shore cage — place → soak → collect (demo soak timer; run-persisted via FishingCatalog).

const PROMPT_PLACE := "下放渔笼"
const PROMPT_WAIT := "查看渔笼"
const PROMPT_COLLECT := "收取渔获"
const SPRITE_EMPTY := "res://assets/sprites/fishing/fish_cage_00.png"
const SPRITE_FULL := "res://assets/sprites/fishing/fish_cage_full_00.png"
## Demo soak (real overnight would use day cycle). 6s keeps loop playable in QA.
const SOAK_MSEC := 6000
const SCRIPT_PATH := "res://scripts/fishing/fish_cage.gd"

var site_id: String = "lake"
var cage_id: String = "cage"
var base_title: String = "渔笼"
var base_desc: String = "岸边可下放隔潮收货的竹笼。"

var _spr: Sprite2D


static func spawn(parent: Node2D, pos: Vector2, size: Vector2, cfg: Dictionary) -> InteractableHotspot:
	## Avoid FishCage.new() before global class cache warms (first-import compile).
	var hs: InteractableHotspot = (load(SCRIPT_PATH) as GDScript).new() as InteractableHotspot
	hs.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	hs.add_child(visual)
	if hs.has_method("configure"):
		hs.call("configure", cfg)
	parent.add_child(hs)
	return hs


func configure(cfg: Dictionary) -> void:
	site_id = str(cfg.get("site_id", site_id))
	cage_id = str(cfg.get("cage_id", cage_id))
	base_title = str(cfg.get("title", "渔笼"))
	base_desc = str(cfg.get("desc", base_desc))
	name = "FishCage_%s_%s" % [site_id, cage_id]
	set_meta("fish_cage", true)
	_ensure_sprite()
	_refresh()


func _ready() -> void:
	super._ready()
	if not activated.is_connected(_on_activated):
		activated.connect(_on_activated)
	_refresh()


func _on_activated(_hs: InteractableHotspot) -> void:
	var st := FishingCatalog.cage_state(site_id, cage_id)
	var phase := str(st.get("phase", "empty"))
	match phase:
		"empty":
			FishingCatalog.cage_place(site_id, cage_id)
			_pulse()
			_play_splash_fx()
		"soaking":
			if FishingCatalog.cage_try_ripen(site_id, cage_id, SOAK_MSEC):
				_pulse()
				_play_splash_fx()
			# else still soaking — copy refresh only
		"ready":
			FishingCatalog.cage_collect(site_id, cage_id)
			_pulse()
			_play_splash_fx()
		_:
			pass
	_refresh()


func _ensure_sprite() -> void:
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	_spr = visual.get_node_or_null("CageSprite") as Sprite2D
	if _spr == null:
		_spr = Sprite2D.new()
		_spr.name = "CageSprite"
		_spr.centered = true
		_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_spr.position = Vector2(0, -8)
		_spr.scale = Vector2(0.95, 0.95)
		_spr.z_index = 2
		visual.add_child(_spr)
	_add_water_ring(visual)


func _add_water_ring(visual: Node2D) -> void:
	if visual.get_node_or_null("WaterRing") != null:
		return
	var ring_tex := WorldSpawnUtil.load_prop_texture("res://assets/sprites/fx/fish_ring_00.png")
	if ring_tex != null:
		var spr := Sprite2D.new()
		spr.name = "WaterRing"
		spr.texture = ring_tex
		spr.centered = true
		spr.position = Vector2(0, 10)
		spr.scale = Vector2(1.15, 1.0)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 0
		visual.add_child(spr)
		return
	push_error("FishCage: missing fish_ring_00.png (Polygon2D ring forbidden)")


func _refresh() -> void:
	var st := FishingCatalog.cage_state(site_id, cage_id)
	var phase := str(st.get("phase", "empty"))
	if phase == "soaking":
		FishingCatalog.cage_try_ripen(site_id, cage_id, SOAK_MSEC)
		st = FishingCatalog.cage_state(site_id, cage_id)
		phase = str(st.get("phase", "empty"))
	var path := SPRITE_EMPTY
	match phase:
		"empty":
			title = base_title
			description = "%s\n状态：空笼 — 点击下放。" % base_desc
			prompt_text = PROMPT_PLACE
		"soaking":
			var left_ms := maxi(0, int(st.get("ready_at", 0)) - Time.get_ticks_msec())
			var left_s := ceili(float(left_ms) / 1000.0)
			title = "%s · 浸泡中" % base_title
			description = "%s\n状态：浸泡中（约 %d 秒后可收；演示加速，正式版按昼夜）。" % [base_desc, left_s]
			prompt_text = PROMPT_WAIT
		"ready":
			path = SPRITE_FULL
			var fish_name := str(st.get("fish_name", "渔获"))
			title = "%s · 可收" % base_title
			description = "%s\n状态：笼内有【%s】— 点击收取。" % [base_desc, fish_name]
			prompt_text = PROMPT_COLLECT
		_:
			pass
	if _spr == null:
		_ensure_sprite()
	if _spr != null:
		var tex := WorldSpawnUtil.load_prop_texture(path)
		if tex != null:
			_spr.texture = tex


func mcp_report() -> Dictionary:
	var st := FishingCatalog.cage_state(site_id, cage_id)
	var sprite_path := ""
	if _spr != null and _spr.texture != null:
		sprite_path = str(_spr.texture.resource_path)
	return {
		"ok": true,
		"phase": str(st.get("phase", "")),
		"title": title,
		"prompt_text": prompt_text,
		"sprite_path": sprite_path,
		"site_id": site_id,
		"cage_id": cage_id,
	}


func mcp_place() -> Dictionary:
	FishingCatalog.cage_place(site_id, cage_id)
	_pulse()
	_play_splash_fx()
	_refresh()
	var out := mcp_report()
	out["ok"] = str(out.get("phase", "")) == "soaking"
	out["fx"] = _fx_report()
	return out


func mcp_collect() -> Dictionary:
	var out_fish := FishingCatalog.cage_collect(site_id, cage_id)
	_pulse()
	_play_splash_fx()
	_refresh()
	var out := mcp_report()
	out["ok"] = str(out.get("phase", "")) == "empty"
	out["collected"] = out_fish
	out["fx"] = _fx_report()
	return out


func mcp_cycle_to_ready() -> Dictionary:
	## Sync probe: empty→place→force ripe→ready (skip 6s soak for MCP/headless).
	var st := FishingCatalog.cage_state(site_id, cage_id)
	var phase := str(st.get("phase", "empty"))
	if phase != "ready":
		if phase == "empty":
			FishingCatalog.cage_place(site_id, cage_id)
		st = FishingCatalog.cage_state(site_id, cage_id)
		st["ready_at"] = Time.get_ticks_msec() - 1
		FishingCatalog.cage_try_ripen(site_id, cage_id, 0)
	_refresh()
	var out := mcp_report()
	out["ok"] = str(out.get("phase", "")) == "ready"
	return out


func _pulse() -> void:
	if _spr == null:
		return
	var tw := _spr.create_tween()
	tw.tween_property(_spr, "modulate", Color(1.25, 1.2, 0.9, 1.0), 0.12)
	tw.tween_property(_spr, "modulate", Color.WHITE, 0.2)


func _play_splash_fx() -> void:
	## Multi-frame shore splash (formal pixels — not modulate-only feedback).
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	var prior := visual.get_node_or_null("FX_fish_splash")
	if prior != null:
		prior.free()
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("oneshot")
	frames.set_animation_loop("oneshot", false)
	frames.set_animation_speed("oneshot", 10.0)
	var n := 0
	for i in range(4):
		var path := "res://assets/sprites/fx/fish_splash_%02d.png" % i
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
	anim.name = "FX_fish_splash"
	anim.sprite_frames = frames
	anim.position = Vector2(0, 8)
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 8
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


func _fx_report() -> Dictionary:
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		return {"ok": false, "reason": "no_visual"}
	var fx := visual.get_node_or_null("FX_fish_splash") as AnimatedSprite2D
	if fx == null:
		return {"ok": false, "reason": "no_fx"}
	var sf := fx.sprite_frames
	var count := 0
	if sf != null and sf.has_animation("oneshot"):
		count = sf.get_frame_count("oneshot")
	return {
		"ok": count >= 4,
		"name": fx.name,
		"frames": count,
		"playing": fx.is_playing(),
	}


func mcp_splash() -> Dictionary:
	## Force splash oneshot for MCP/runtime evidence without changing cage phase.
	_play_splash_fx()
	return _fx_report()
