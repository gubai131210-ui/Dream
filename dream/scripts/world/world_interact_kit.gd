class_name WorldInteractKit
extends Node

## C58 — ≥8 world interact types as live hotspots on village_square.
## Visuals: outdoor props (not debug diamonds). Feedback: Info + short local FX.

const NODE_NAME := "WorldInteractKit"
const PROP := "res://assets/sprites/props"

const INTERACT_DEFS := [
	{
		"id": "sit_bench",
		"title": "长椅",
		"desc": "坐一会儿，听广场闲谈。",
		"pos": Vector2(420, 620),
		"color": Color(0.72, 0.55, 0.32, 0.92),
		"sprite": PROP + "/bench_0.png",
		"scale": 0.55,
	},
	{
		"id": "well_water",
		"title": "井水",
		"desc": "打一桶清凉井水。",
		"pos": Vector2(700, 560),
		"color": Color(0.4, 0.7, 0.95, 0.92),
		"sprite": PROP + "/well_0.png",
		"scale": 0.5,
	},
	{
		"id": "shake_tree",
		"title": "摇树",
		"desc": "摇晃庭树，落下一片叶子。",
		"pos": Vector2(180, 300),
		"color": Color(0.35, 0.75, 0.4, 0.92),
		"sprite": "res://assets/sprites/trees/grounded/tree_00.png",
		"scale": 0.42,
	},
	{
		"id": "notice_board",
		"title": "公告栏",
		"desc": "本周集市与庆典告示。",
		"pos": Vector2(860, 280),
		"color": Color(0.9, 0.78, 0.4, 0.92),
		"sprite": PROP + "/B11-06_mailbox_board_02.png",
		"scale": 0.55,
	},
	{
		"id": "crate_search",
		"title": "木箱",
		"desc": "翻找补给箱，空空如也。",
		"pos": Vector2(1100, 620),
		"color": Color(0.7, 0.5, 0.3, 0.92),
		"sprite": PROP + "/crate_1.png",
		"scale": 0.55,
	},
	{
		"id": "lamp_toggle",
		"title": "路灯",
		"desc": "拨亮/熄灭广场路灯。夜间灯柱会照亮周围地面。",
		"pos": Vector2(300, 240),
		"color": Color(1.0, 0.88, 0.45, 0.92),
		"sprite": PROP + "/lamp_0.png",
		"scale": 1.15,
	},
	{
		"id": "feed_critter",
		"title": "喂鸟",
		"desc": "撒一把谷粒，麻雀飞来。",
		"pos": Vector2(980, 700),
		"color": Color(0.85, 0.65, 0.5, 0.92),
		"sprite": PROP + "/sack_0.png",
		"scale": 0.5,
	},
	{
		"id": "read_sign",
		"title": "路牌",
		"desc": "东市集 · 西农舍 · 北教堂。",
		"pos": Vector2(520, 200),
		"color": Color(0.65, 0.7, 0.55, 0.92),
		"sprite": PROP + "/B11-06_mailbox_board_00.png",
		"scale": 0.5,
	},
]

signal interacted(interact_id: String)

var _info: InfoPanel
var _root: Node2D
var _lamp_on: bool = true
var _lamp_light: PointLight2D
var _lamp_sprite: Sprite2D
var _hotspots: Dictionary = {}


static func attach_to(host: Node2D, top_bar: Control = null) -> WorldInteractKit:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as WorldInteractKit
	if existing:
		return existing
	var kit := WorldInteractKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for d in INTERACT_DEFS:
		out.append({"id": d["id"], "title": d["title"], "hint": d["desc"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


func setup(host: Node2D, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "WorldInteractRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	for d in INTERACT_DEFS:
		var interact_id := str(d["id"])
		var title := str(d["title"])
		var desc := str(d["desc"])
		var sprite_path := str(d.get("sprite", ""))
		var scale_f := float(d.get("scale", 0.55))
		# scale 0 → intentional no prop (rely on nearby district art, e.g. shake_tree).
		if scale_f <= 0.0:
			sprite_path = ""
		var hs := WorldSpawnUtil.make_hotspot(
			_root,
			title,
			desc,
			d["pos"] as Vector2,
			Vector2(56, 48),
			d["color"] as Color,
			sprite_path,
			scale_f if scale_f > 0.0 else 0.55,
		)
		hs.set_meta("interact_id", interact_id)
		_hotspots[interact_id] = hs
		if interact_id == "lamp_toggle":
			_setup_lamp(hs)
		if interact_id == "shake_tree":
			# Formal tree prop is required; polygon canopy is not a production path.
			if hs.get_node_or_null("Visual/PropSprite") == null:
				push_error("WorldInteractKit: shake_tree missing PropSprite (tree_00 required)")
		hs.activated.connect(func(_h: InteractableHotspot) -> void:
			_handle_interact(interact_id, title, desc)
		)


func live_count() -> int:
	return INTERACT_DEFS.size()


func _setup_lamp(hs: InteractableHotspot) -> void:
	_lamp_sprite = hs.get_node_or_null("Visual/PropSprite") as Sprite2D
	_lamp_light = PointLight2D.new()
	_lamp_light.name = "LampLight"
	WorldSpawnUtil.configure_lamp_light(_lamp_light, Color(1.0, 0.82, 0.52, 1.0), WorldSpawnUtil.LAMP_ENERGY_NIGHT, WorldSpawnUtil.LAMP_TEX_SCALE, WorldSpawnUtil.LAMP_TEX_SIZE)
	_lamp_light.position = WorldSpawnUtil.LAMP_LIGHT_OFFSET
	hs.get_node("Visual").add_child(_lamp_light)
	hs.set_meta("lamp_on", true)
	_lamp_on = true
	# Re-scan so kit tracks this light for night/day energy.
	var host := get_parent() as Node2D
	if host:
		var _olk := load("res://scripts/world/outdoor_lamp_kit.gd")
		if _olk:
			_olk.attach_to(host)


func _handle_interact(interact_id: String, title: String, desc: String) -> void:
	var body := desc
	var hs: Node = _hotspots.get(interact_id) as Node
	if hs == null:
		push_warning("WorldInteractKit: hotspot missing for %s" % interact_id)
	match interact_id:
		"lamp_toggle":
			_lamp_on = not _lamp_on
			body = "路灯已%s。" % ("点亮" if _lamp_on else "熄灭")
			if _lamp_light:
				_lamp_light.enabled = _lamp_on
				_lamp_light.energy = WorldSpawnUtil.LAMP_ENERGY_NIGHT if _lamp_on else 0.0
			if hs:
				hs.set_meta("lamp_on", _lamp_on)
			if _lamp_sprite:
				_lamp_sprite.modulate = Color(1.2, 1.08, 0.82) if _lamp_on else Color(0.55, 0.55, 0.65)
			if _lamp_on:
				var env := DayNightWeather.find_on(get_parent())
				if env and not env.is_night():
					env.pulse_dusk_for_lamps()
					body += "（已切夜间观灯；关灯或按 N 回白天）"
			else:
				var env_off := DayNightWeather.find_on(get_parent())
				if env_off:
					var restored := env_off.restore_day_from_lamps()
					if bool(restored.get("ok", false)) and bool(restored.get("restored", false)):
						body += "（已回白天）"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/fx", "lamp_spark", 4, Vector2(0, -30), 10.0)
		"shake_tree":
			body = "树叶沙沙作响，一片叶子飘落。"
			_pulse_visual(hs)
			_spawn_leaf_burst(hs)
		"well_water":
			body = "井绳吱呀，打上一桶清凉井水。"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/props", "well_rope", 4, Vector2(0, -22), 8.0)
		"feed_critter":
			body = "谷粒刚落地，几只麻雀扑棱飞来。"
			_pulse_visual(hs)
			_spawn_grain_burst(hs)
		"sit_bench":
			body = "长椅微微晃动，广场闲谈声近了。"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/fx", "bench_dust", 4, Vector2(0, 6), 10.0)
		"crate_search":
			body = "木箱里只有干草与空瓶。"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/props", "crate_lid", 4, Vector2(0, -18), 8.0)
		"notice_board":
			body = "告示：周末秋收市集，广场张灯。"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/fx", "board_rustle", 4, Vector2(0, -20), 10.0)
		"read_sign":
			body = "路牌：东市集 · 西农舍 · 北教堂。"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/fx", "board_rustle", 4, Vector2(0, -20), 10.0)
	if _info:
		_info.show_info(title, body)
	interacted.emit(interact_id)


func mcp_spawn_c58_fx(interact_id: String) -> Dictionary:
	## Sync probe for MCP / headless: spawn FX and report node + frame count before free.
	var hs: Node = _hotspots.get(interact_id) as Node
	if hs == null:
		return {"ok": false, "reason": "missing_hotspot", "id": interact_id}
	match interact_id:
		"well_water":
			_play_fx_clip(hs, "res://assets/sprites/props", "well_rope", 4, Vector2(0, -22), 8.0)
		"crate_search":
			_play_fx_clip(hs, "res://assets/sprites/props", "crate_lid", 4, Vector2(0, -18), 8.0)
		"shake_tree":
			_spawn_leaf_burst(hs)
		"feed_critter":
			_spawn_grain_burst(hs)
		"sit_bench":
			_play_fx_clip(hs, "res://assets/sprites/fx", "bench_dust", 4, Vector2(0, 6), 10.0)
		"notice_board", "read_sign":
			_play_fx_clip(hs, "res://assets/sprites/fx", "board_rustle", 4, Vector2(0, -20), 10.0)
		"lamp_toggle":
			_play_fx_clip(hs, "res://assets/sprites/fx", "lamp_spark", 4, Vector2(0, -30), 10.0)
		_:
			return {"ok": false, "reason": "unsupported_id", "id": interact_id}
	var visual := hs.get_node_or_null("Visual") as Node
	if visual == null:
		return {"ok": false, "reason": "missing_visual", "id": interact_id}
	var fx_name := ""
	match interact_id:
		"well_water":
			fx_name = "FX_well_rope"
		"crate_search":
			fx_name = "FX_crate_lid"
		"shake_tree":
			fx_name = "FX_leaf_fall"
		"feed_critter":
			fx_name = "FX_bird_peck"
		"sit_bench":
			fx_name = "FX_bench_dust"
		"notice_board", "read_sign":
			fx_name = "FX_board_rustle"
		"lamp_toggle":
			fx_name = "FX_lamp_spark"
	var fx := visual.get_node_or_null(fx_name) as AnimatedSprite2D
	if fx == null:
		return {"ok": false, "reason": "fx_not_spawned", "id": interact_id, "visual_children": visual.get_child_count()}
	var sf := fx.sprite_frames
	var frames := 0
	if sf != null and sf.has_animation("oneshot"):
		frames = sf.get_frame_count("oneshot")
	var out := {
		"ok": true,
		"id": interact_id,
		"fx": fx_name,
		"frames": frames,
		"playing": fx.is_playing(),
		"path": str(fx.get_path()),
	}
	if interact_id == "lamp_toggle" and _lamp_light != null:
		out["has_light"] = true
		out["has_light_texture"] = _lamp_light.texture != null
		out["light_enabled"] = _lamp_light.enabled
		out["light_energy"] = _lamp_light.energy
		out["lamp_on"] = _lamp_on
	return out


func mcp_activate(interact_id: String) -> Dictionary:
	## Sync MCP: run full interact handler (lamp toggle + FX + Info).
	for d in INTERACT_DEFS:
		if str(d.get("id", "")) != interact_id:
			continue
		_handle_interact(interact_id, str(d.get("title", "")), str(d.get("desc", "")))
		var out := {"ok": true, "id": interact_id}
		if interact_id == "lamp_toggle" and _lamp_light != null:
			out["lamp_on"] = _lamp_on
			out["light_enabled"] = _lamp_light.enabled
			out["light_energy"] = _lamp_light.energy
			out["has_light_texture"] = _lamp_light.texture != null
		return out
	return {"ok": false, "reason": "unknown_id", "id": interact_id}


func _pulse_visual(hs: Node) -> void:
	if hs == null:
		return
	var visual := hs.get_node_or_null("Visual") as CanvasItem
	if visual == null:
		return
	var tw := visual.create_tween()
	tw.tween_property(visual, "modulate", Color(1.25, 1.2, 0.9), 0.08)
	tw.tween_property(visual, "modulate", Color.WHITE, 0.18)


func _play_fx_clip(hs: Node, dir_path: String, prefix: String, frame_count: int, local_pos: Vector2, fps: float = 10.0) -> void:
	if hs == null:
		return
	var visual := hs.get_node_or_null("Visual") as Node2D
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
	for i in range(frame_count):
		var path := "%s/%s_%02d.png" % [dir_path, prefix, i]
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
			continue
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
		if tex == null:
			var img := Image.load_from_file(ProjectSettings.globalize_path(path))
			if img != null:
				tex = ImageTexture.create_from_image(img)
		if tex == null:
			continue
		frames.add_frame("oneshot", tex)
		n += 1
	if n == 0:
		push_warning("WorldInteractKit: no FX frames for %s in %s" % [prefix, dir_path])
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "FX_%s" % prefix
	anim.sprite_frames = frames
	anim.position = local_pos
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 8
	anim.centered = true
	visual.add_child(anim)
	anim.play("oneshot")
	# Pause on last frame so MCP / screenshots can observe FX_* after the oneshot.
	# Re-trigger paths free prior FX_%s before spawning a new clip.
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


func _spawn_leaf_burst(hs: Node) -> void:
	_play_fx_clip(hs, "res://assets/sprites/fx", "leaf_fall", 4, Vector2(0, -18), 12.0)


func _spawn_grain_burst(hs: Node) -> void:
	_play_fx_clip(hs, "res://assets/sprites/fx", "bird_peck", 4, Vector2(10, -8), 10.0)
	# Bird frames are 32×32 — bump display scale so peck reads at plaza zoom.
	if hs != null:
		var visual := hs.get_node_or_null("Visual") as Node
		if visual:
			var fx := visual.get_node_or_null("FX_bird_peck") as AnimatedSprite2D
			if fx:
				fx.scale = Vector2(1.75, 1.75)
