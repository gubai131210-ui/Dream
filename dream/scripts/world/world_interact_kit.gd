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
		"sprite": "",
		"scale": 0.0,
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
		"desc": "拨亮/熄灭广场路灯（本地示意）。",
		"pos": Vector2(300, 240),
		"color": Color(1.0, 0.88, 0.45, 0.92),
		"sprite": PROP + "/lamp_0.png",
		"scale": 0.55,
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
			_setup_tree_marker(hs)
		hs.activated.connect(func(_h: InteractableHotspot) -> void:
			_handle_interact(interact_id, title, desc)
		)


func live_count() -> int:
	return INTERACT_DEFS.size()


func _setup_lamp(hs: InteractableHotspot) -> void:
	_lamp_sprite = hs.get_node_or_null("Visual/PropSprite") as Sprite2D
	_lamp_light = PointLight2D.new()
	_lamp_light.name = "LampLight"
	_lamp_light.color = Color(1.0, 0.85, 0.45, 1.0)
	_lamp_light.energy = 0.85
	_lamp_light.texture_scale = 1.4
	_lamp_light.position = Vector2(0, -28)
	hs.get_node("Visual").add_child(_lamp_light)


func _setup_tree_marker(hs: InteractableHotspot) -> void:
	## Soft canopy cue so the interact is discoverable without a fake barrel sprite.
	var canopy := Polygon2D.new()
	canopy.name = "TreeCanopyCue"
	canopy.color = Color(0.28, 0.55, 0.32, 0.55)
	canopy.polygon = PackedVector2Array([
		Vector2(0, -36), Vector2(22, -18), Vector2(14, 4), Vector2(-14, 4), Vector2(-22, -18),
	])
	canopy.z_index = 0
	hs.get_node("Visual").add_child(canopy)
	var trunk := Polygon2D.new()
	trunk.name = "TreeTrunkCue"
	trunk.color = Color(0.45, 0.3, 0.18, 0.9)
	trunk.polygon = PackedVector2Array([
		Vector2(-4, 4), Vector2(4, 4), Vector2(3, 18), Vector2(-3, 18),
	])
	hs.get_node("Visual").add_child(trunk)


func _handle_interact(interact_id: String, title: String, desc: String) -> void:
	var body := desc
	var hs: InteractableHotspot = _hotspots.get(interact_id) as InteractableHotspot
	match interact_id:
		"lamp_toggle":
			_lamp_on = not _lamp_on
			body = "路灯已%s。" % ("点亮" if _lamp_on else "熄灭")
			if _lamp_light:
				_lamp_light.enabled = _lamp_on
				_lamp_light.energy = 0.85 if _lamp_on else 0.0
			if _lamp_sprite:
				_lamp_sprite.modulate = Color(1.15, 1.05, 0.8) if _lamp_on else Color(0.55, 0.55, 0.65)
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
		"crate_search":
			body = "木箱里只有干草与空瓶。"
			_pulse_visual(hs)
			_play_fx_clip(hs, "res://assets/sprites/props", "crate_lid", 4, Vector2(0, -18), 8.0)
		"notice_board":
			body = "告示：周末秋收市集，广场张灯。"
			_pulse_visual(hs)
		"read_sign":
			body = "路牌：东市集 · 西农舍 · 北教堂。"
			_pulse_visual(hs)
	if _info:
		_info.show_info(title, body)
	interacted.emit(interact_id)


func _pulse_visual(hs: InteractableHotspot) -> void:
	if hs == null:
		return
	var visual := hs.get_node_or_null("Visual") as CanvasItem
	if visual == null:
		return
	var tw := visual.create_tween()
	tw.tween_property(visual, "modulate", Color(1.25, 1.2, 0.9), 0.08)
	tw.tween_property(visual, "modulate", Color.WHITE, 0.18)


func _play_fx_clip(hs: InteractableHotspot, dir_path: String, prefix: String, frame_count: int, local_pos: Vector2, fps: float = 10.0) -> void:
	if hs == null:
		return
	var visual := hs.get_node_or_null("Visual") as Node2D
	if visual == null:
		return
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
	anim.animation_finished.connect(func() -> void:
		if is_instance_valid(anim):
			anim.queue_free()
	)


func _spawn_leaf_burst(hs: InteractableHotspot) -> void:
	_play_fx_clip(hs, "res://assets/sprites/fx", "leaf_fall", 4, Vector2(0, -18), 12.0)
	# Keep a couple of drifting diamonds as secondary dust if clip missing.
	if hs == null or _root == null:
		return
	if ResourceLoader.exists("res://assets/sprites/fx/leaf_fall_00.png"):
		return
	for i in range(5):
		var leaf := Polygon2D.new()
		leaf.color = Color(0.45, 0.75, 0.35, 0.95)
		leaf.polygon = PackedVector2Array([
			Vector2(0, -4), Vector2(3, 0), Vector2(0, 4), Vector2(-3, 0),
		])
		leaf.position = hs.global_position + Vector2(randf_range(-8, 8), -20)
		_root.add_child(leaf)
		var tw := leaf.create_tween()
		var end := leaf.position + Vector2(randf_range(-24, 24), randf_range(28, 48))
		tw.tween_property(leaf, "position", end, 0.55).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(leaf, "modulate:a", 0.0, 0.55)
		tw.tween_callback(leaf.queue_free)


func _spawn_grain_burst(hs: InteractableHotspot) -> void:
	_play_fx_clip(hs, "res://assets/sprites/fx", "bird_peck", 4, Vector2(10, -8), 10.0)
	if hs == null or _root == null:
		return
	if ResourceLoader.exists("res://assets/sprites/fx/bird_peck_00.png"):
		return
	for i in range(6):
		var grain := Polygon2D.new()
		grain.color = Color(0.9, 0.78, 0.4, 0.95)
		grain.polygon = PackedVector2Array([
			Vector2(-2, -1), Vector2(2, -1), Vector2(2, 1), Vector2(-2, 1),
		])
		grain.position = hs.global_position + Vector2(randf_range(-6, 6), -4)
		_root.add_child(grain)
		var tw := grain.create_tween()
		var end := grain.position + Vector2(randf_range(-18, 18), randf_range(8, 22))
		tw.tween_property(grain, "position", end, 0.4)
		tw.parallel().tween_property(grain, "modulate:a", 0.0, 0.4)
		tw.tween_callback(grain.queue_free)
