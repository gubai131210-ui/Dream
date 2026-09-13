class_name BreakablesKit
extends Node

## C59 — ≥4 clearable breakables on village_square (click to remove).

const NODE_NAME := "BreakablesKit"

const KIND_DEFS := [
	{"id": "rock", "title": "碎石堆", "desc": "砸开碎石，清出小路。", "pos": Vector2(150, 680), "color": Color(0.55, 0.55, 0.58, 0.95), "sprite": "res://assets/sprites/props/rock_02.png", "scale": 0.55},
	{"id": "stake", "title": "木桩", "desc": "拔起旧木桩。", "pos": Vector2(1180, 360), "color": Color(0.62, 0.42, 0.28, 0.95), "sprite": "res://assets/sprites/props/breakable_stake_00.png", "scale": 0.7},
	{"id": "weed", "title": "杂草丛", "desc": "割净杂草。", "pos": Vector2(760, 720), "color": Color(0.4, 0.7, 0.35, 0.95), "sprite": "res://assets/sprites/props/breakable_weed_00.png", "scale": 0.65},
	{"id": "crate", "title": "破箱", "desc": "砸开废弃破箱。", "pos": Vector2(1040, 240), "color": Color(0.7, 0.48, 0.3, 0.95), "sprite": "res://assets/sprites/props/crate_2.png", "scale": 0.55},
]

signal cleared(kind_id: String)

var _info: InfoPanel
var _root: Node2D
var _cleared: Dictionary = {}


static func attach_to(host: Node2D, top_bar: Control = null) -> BreakablesKit:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as BreakablesKit
	if existing:
		return existing
	var kit := BreakablesKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for d in KIND_DEFS:
		out.append({"id": d["id"], "title": d["title"], "hint": d["desc"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


func setup(host: Node2D, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "BreakablesRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	for d in KIND_DEFS:
		_spawn_one(d)


func live_count() -> int:
	return KIND_DEFS.size()


func cleared_count() -> int:
	return _cleared.size()


func mcp_clear(kind_id: String) -> Dictionary:
	## Sync probe for MCP / headless: clear one breakable and report remaining.
	if _root == null:
		return {"ok": false, "reason": "no_root", "id": kind_id}
	if _cleared.has(kind_id):
		return {"ok": false, "reason": "already_cleared", "id": kind_id}
	for child in _root.get_children():
		if child is InteractableHotspot and str(child.get_meta("breakable_id", "")) == kind_id:
			var hs := child as InteractableHotspot
			_clear_breakable(kind_id, hs.title, hs)
			var fx_node: AnimatedSprite2D = null
			var visual := hs.get_node_or_null("Visual") as Node
			if visual:
				for c in visual.get_children():
					if c is AnimatedSprite2D and str(c.name).begins_with("FX_"):
						fx_node = c as AnimatedSprite2D
						break
			return {
				"ok": true,
				"id": kind_id,
				"cleared": cleared_count(),
				"remaining_nodes": _root.get_child_count() - 1, # queue_free deferred
				"fx": str(fx_node.name) if fx_node else "",
				"fx_playing": fx_node.is_playing() if fx_node else false,
			}
	return {"ok": false, "reason": "missing_hotspot", "id": kind_id}


func _spawn_one(d: Dictionary) -> void:
	var kind_id := str(d["id"])
	var title := str(d["title"])
	var desc := str(d["desc"])
	var hs := WorldSpawnUtil.make_hotspot(
		_root,
		title,
		desc + "（点击清除）",
		d["pos"] as Vector2,
		Vector2(52, 44),
		d["color"] as Color,
		str(d.get("sprite", "")),
		float(d.get("scale", 0.55)),
	)
	hs.set_meta("breakable_id", kind_id)
	hs.activated.connect(func(h: InteractableHotspot) -> void:
		_clear_breakable(kind_id, title, h)
	)


func _clear_breakable(kind_id: String, title: String, hs: InteractableHotspot) -> void:
	if _cleared.has(kind_id):
		return
	_cleared[kind_id] = true
	if _info:
		_info.show_info(title, "已清除「%s」。" % title)
	cleared.emit(kind_id)
	if not is_instance_valid(hs):
		return
	# Hide body immediately; play short debris FX, then free.
	var body := hs.get_node_or_null("Visual/PropSprite") as CanvasItem
	if body:
		body.visible = false
	var prompt := hs.get_node_or_null("ProximityPrompt") as CanvasItem
	if prompt:
		prompt.visible = false
	_play_clear_fx(hs, kind_id)
	var tw := hs.create_tween()
	tw.tween_interval(0.55)
	tw.tween_callback(func() -> void:
		if is_instance_valid(hs):
			hs.queue_free()
	)


func _play_clear_fx(hs: InteractableHotspot, kind_id: String) -> void:
	var dir := "res://assets/sprites/fx"
	var prefix := "bench_dust"
	var local := Vector2(0, 0)
	var fps := 12.0
	match kind_id:
		"weed", "rock":
			prefix = "leaf_fall"
			local = Vector2(0, -8)
		"crate":
			dir = "res://assets/sprites/props"
			prefix = "crate_lid"
			local = Vector2(0, -12)
			fps = 8.0
		"stake":
			prefix = "bench_dust"
			local = Vector2(0, 4)
		_:
			pass
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
	anim.z_index = 8
	anim.centered = true
	visual.add_child(anim)
	anim.play("oneshot")
