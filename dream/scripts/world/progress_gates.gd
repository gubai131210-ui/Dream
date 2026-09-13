class_name ProgressGates
extends Node

## C60 — ≥3 progress gates with unlock stub (click → unlock / clear).

const NODE_NAME := "ProgressGates"

const GATE_DEFS := [
	{
		"id": "fallen_log",
		"title": "倒木",
		"locked": "倒下的粗木挡住了小路。点击解锁（剧情/工具桩）。",
		"unlocked": "倒木已移开，小路通畅。",
		"pos": Vector2(200, 780),
		"color": Color(0.5, 0.35, 0.22, 0.95),
		"sprite": "res://assets/sprites/props/gate_log_00.png",
		"scale": 0.65,
	},
	{
		"id": "boulder",
		"title": "巨石",
		"locked": "巨石堵住捷径。点击解锁（升级桩）。",
		"unlocked": "巨石滚到路旁，捷径打开。",
		"pos": Vector2(1120, 760),
		"color": Color(0.5, 0.52, 0.55, 0.95),
		"sprite": "res://assets/sprites/props/rock_04.png",
		"scale": 0.7,
	},
	{
		"id": "locked_door",
		"title": "锁门",
		"locked": "铁锁门紧闭。点击解锁（钥匙桩）。",
		"unlocked": "锁已打开，门扇轻推即入。",
		"pos": Vector2(80, 480),
		"color": Color(0.55, 0.45, 0.65, 0.95),
		"sprite": "res://assets/sprites/props/gate_locked_door_00.png",
		"scale": 0.55,
	},
]

signal unlocked(gate_id: String)

var _info: InfoPanel
var _root: Node2D
var _unlocked: Dictionary = {}


static func attach_to(host: Node2D, top_bar: Control = null) -> ProgressGates:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as ProgressGates
	if existing:
		return existing
	var kit := ProgressGates.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for d in GATE_DEFS:
		out.append({"id": d["id"], "title": d["title"], "hint": d["locked"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


func setup(host: Node2D, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "ProgressGatesRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	for d in GATE_DEFS:
		_spawn_one(d)


func live_count() -> int:
	return GATE_DEFS.size()


func unlocked_count() -> int:
	return _unlocked.size()


func is_unlocked(gate_id: String) -> bool:
	return bool(_unlocked.get(gate_id, false))


func unlock(gate_id: String) -> void:
	if _unlocked.get(gate_id, false):
		return
	_unlocked[gate_id] = true
	unlocked.emit(gate_id)
	var unlocked_blurb := "已解锁。"
	for d in GATE_DEFS:
		if str(d.get("id", "")) == gate_id:
			unlocked_blurb = str(d.get("unlocked", unlocked_blurb))
			break
	for child in _root.get_children():
		if child is InteractableHotspot and str(child.get_meta("gate_id", "")) == gate_id:
			var hs := child as InteractableHotspot
			hs.description = unlocked_blurb
			var visual := hs.get_node_or_null("Visual/Marker") as Polygon2D
			if visual:
				visual.color = Color(0.45, 0.85, 0.5, 0.85)
			var tag := hs.get_node_or_null("Visual/Tag") as Label
			if tag:
				tag.text = hs.title + "·通"
			var spr := hs.get_node_or_null("Visual/PropSprite") as Sprite2D
			if spr:
				spr.modulate = Color(0.7, 0.9, 0.7, 0.45)
			_play_unlock_fx(hs, gate_id)
			if _info:
				_info.show_info(hs.title + "·通", unlocked_blurb)
			break


func _play_unlock_fx(hs: InteractableHotspot, gate_id: String) -> void:
	if hs == null:
		return
	var dir := "res://assets/sprites/fx"
	var prefix := "bench_dust"
	var local := Vector2(0, -8)
	var fps := 12.0
	match gate_id:
		"locked_door":
			prefix = "board_rustle"
			local = Vector2(0, -20)
			fps = 10.0
		"fallen_log":
			prefix = "leaf_fall"
			local = Vector2(0, -10)
		"boulder":
			prefix = "bench_dust"
			local = Vector2(0, 2)
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


func mcp_unlock(gate_id: String) -> Dictionary:
	## Sync probe for MCP / headless: unlock one gate and report sprite soften.
	if _root == null:
		return {"ok": false, "reason": "no_root", "id": gate_id}
	if is_unlocked(gate_id):
		return {"ok": false, "reason": "already_unlocked", "id": gate_id}
	var found := false
	var modulate_a := -1.0
	var fx_name := ""
	var fx_playing := false
	var fx_frames := 0
	for child in _root.get_children():
		if child is InteractableHotspot and str(child.get_meta("gate_id", "")) == gate_id:
			found = true
			unlock(gate_id)
			var spr := child.get_node_or_null("Visual/PropSprite") as Sprite2D
			if spr:
				modulate_a = spr.modulate.a
			var visual := child.get_node_or_null("Visual") as Node
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
			break
	if not found:
		return {"ok": false, "reason": "missing_hotspot", "id": gate_id}
	return {
		"ok": true,
		"id": gate_id,
		"unlocked_count": unlocked_count(),
		"sprite_alpha": modulate_a,
		"fx": fx_name,
		"fx_playing": fx_playing,
		"fx_frames": fx_frames,
	}


func _spawn_one(d: Dictionary) -> void:
	var gate_id := str(d["id"])
	var title := str(d["title"])
	var locked := str(d["locked"])
	var unlocked_msg := str(d["unlocked"])
	var hs := WorldSpawnUtil.make_hotspot(
		_root,
		title,
		locked,
		d["pos"] as Vector2,
		Vector2(64, 52),
		d["color"] as Color,
		str(d.get("sprite", "")),
		float(d.get("scale", 0.55)),
	)
	hs.set_meta("gate_id", gate_id)
	hs.activated.connect(func(h: InteractableHotspot) -> void:
		if is_unlocked(gate_id):
			if _info:
				_info.show_info(title, unlocked_msg)
			return
		unlock(gate_id)
		if _info:
			_info.show_info(title, unlocked_msg)
		h.modulate = Color(1, 1, 1, 0.35)
	)
