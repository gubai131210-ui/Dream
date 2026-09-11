class_name InteriorCraft
extends Node

## Profile-driven interior assembler (PHASE5 / INTERIOR_FOUNDATION / INTERIOR_ROOM_BRIEFS).
## Pass: floor → walls/door/window → rug → props → FX → ambient → lights → actor → portal.
## 32px grid. Distinct floor sets + specialty props. Local lights only.

const TILE := 32
const ORIGIN := Vector2i(4, 4)
const WALL_THICK := 2
const TILE_DIR := "res://assets/sprites/interior/tiles"
const FX_DIR := "res://assets/sprites/interior/fx"
const PROP_SCALE := 0.9

@export var profile_id: String = "c01_home"

var _profile: Dictionary = {}
var _room_w: int = 32
var _room_h: int = 20
var _door_tx0: int = 14
var _door_tx1: int = 17
var _floor_kind: String = "plank"


func assemble(root: Node2D, override_profile: String = "") -> void:
	var pid := override_profile if not override_profile.is_empty() else profile_id
	if root.has_meta("profile_id"):
		pid = str(root.get_meta("profile_id"))
	_profile = InteriorProfiles.get_profile(pid)
	profile_id = pid
	_room_w = int(_profile.get("room_w", 32))
	_room_h = int(_profile.get("room_h", 20))
	_door_tx0 = int(_profile.get("door_tx0", 14))
	_door_tx1 = int(_profile.get("door_tx1", 17))
	_floor_kind = str(_profile.get("floor", "plank"))

	var world := root.get_node_or_null("InteriorWorld") as Node2D
	if world == null:
		world = Node2D.new()
		world.name = "InteriorWorld"
		world.y_sort_enabled = true
		world.z_index = 2
		root.add_child(world)
	else:
		for c in world.get_children():
			c.free()

	var foundation := Node2D.new()
	foundation.name = "Foundation"
	foundation.z_index = -20
	world.add_child(foundation)
	_paint_floor(foundation)
	_paint_walls(foundation)
	_paint_door_and_window(foundation)
	_paint_rug(foundation)

	_spawn_furniture(world)
	_spawn_fx(world)
	_spawn_ambient(world)
	_spawn_local_lights(world)
	_spawn_actor(world)
	_spawn_return_portal(world)
	_apply_topbar_hint(root)


func room_rect() -> Rect2:
	return Rect2(
		float(ORIGIN.x * TILE),
		float(ORIGIN.y * TILE),
		float(_room_w * TILE),
		float(_room_h * TILE),
	)


func _tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((ORIGIN.x + tx) * TILE + TILE * 0.5, (ORIGIN.y + ty) * TILE + TILE * 0.5)


func _spawn_tile(parent: Node2D, path: String, tx: int, ty: int, z: int = 0) -> void:
	if not ResourceLoader.exists(path):
		return
	var spr := Sprite2D.new()
	spr.texture = load(path) as Texture2D
	spr.centered = true
	spr.position = _tile_center(tx, ty)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = z
	parent.add_child(spr)


func _floor_path(tx: int, ty: int) -> String:
	var idx := (tx + ty * 3) % 4
	match _floor_kind:
		"straw":
			return "%s/floor_straw_%02d.png" % [TILE_DIR, idx]
		"stone":
			return "%s/floor_stone_%02d.png" % [TILE_DIR, idx]
		"dark":
			return "%s/floor_dark_%02d.png" % [TILE_DIR, idx]
		_:
			return "%s/floor_%02d.png" % [TILE_DIR, idx]


func _paint_floor(parent: Node2D) -> void:
	for ty in range(WALL_THICK, _room_h):
		for tx in range(_room_w):
			_spawn_tile(parent, _floor_path(tx, ty), tx, ty, -5)


func _paint_walls(parent: Node2D) -> void:
	for tx in range(_room_w):
		_spawn_tile(parent, "%s/wall_upper_%02d.png" % [TILE_DIR, tx % 4], tx, 0, -2)
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, tx % 4], tx, 1, -1)
	for tx in [0, maxi(1, _room_w / 3), maxi(2, (_room_w * 2) / 3), _room_w - 1]:
		_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, tx, 0, 0)
		_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, tx, 1, 0)
	for ty in range(WALL_THICK, _room_h):
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, ty % 4], 0, ty, -1)
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, (ty + 1) % 4], _room_w - 1, ty, -1)


func _paint_door_and_window(parent: Node2D) -> void:
	for tx in range(_door_tx0, _door_tx1 + 1):
		_spawn_tile(parent, "%s/doorstep_00.png" % TILE_DIR, tx, _room_h - 1, 1)
	_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, _door_tx0 - 1, _room_h - 1, 2)
	_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, _door_tx1 + 1, _room_h - 1, 2)
	var door_frame := "%s/door_frame_00.png" % TILE_DIR
	if ResourceLoader.exists(door_frame):
		for tx in [_door_tx0 - 1, _door_tx1 + 1]:
			var spr := Sprite2D.new()
			spr.texture = load(door_frame) as Texture2D
			spr.centered = true
			spr.position = _tile_center(tx, _room_h - 2)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.z_index = 2
			parent.add_child(spr)
	if bool(_profile.get("window", true)):
		var win_path := "%s/window_00.png" % TILE_DIR
		if ResourceLoader.exists(win_path):
			var spr := Sprite2D.new()
			spr.texture = load(win_path) as Texture2D
			spr.centered = true
			spr.position = _tile_center(int(_room_w / 2), 0) + Vector2(16, 16)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.z_index = 3
			parent.add_child(spr)
		var mid := int(_room_w / 2)
		var shaft := Polygon2D.new()
		shaft.name = "WindowLightShaft"
		shaft.color = Color(1.0, 0.92, 0.65, 0.12)
		shaft.polygon = PackedVector2Array([
			_tile_center(mid - 2, 2) + Vector2(-16, -8),
			_tile_center(mid + 2, 2) + Vector2(16, -8),
			_tile_center(mid + 3, 7) + Vector2(8, 0),
			_tile_center(mid - 3, 7) + Vector2(-8, 0),
		])
		shaft.z_index = -3
		parent.add_child(shaft)


func _paint_rug(parent: Node2D) -> void:
	if not _profile.has("rug") or _profile["rug"] == null:
		return
	var rug: Dictionary = _profile.get("rug", {})
	if rug.is_empty():
		return
	var ox: int = int(rug.get("ox", 14))
	var oy: int = int(rug.get("oy", 12))
	for qy in range(2):
		for qx in range(2):
			_spawn_tile(parent, "%s/rug_%d_%d.png" % [TILE_DIR, qy, qx], ox + qx, oy + qy, 0)


func _spawn_furniture(parent: Node2D) -> void:
	var props: Array = _profile.get("props", [])
	for p in props:
		var path: String = str(p.get("path", ""))
		var scale_f: float = float(p.get("scale", PROP_SCALE))
		_spawn_prop(
			parent,
			path,
			_tile_center(int(p.get("tx", 0)), int(p.get("ty", 0))),
			scale_f,
			str(p.get("title", "物件")),
			str(p.get("desc", "")),
		)


func _spawn_prop(parent: Node2D, path: String, pos: Vector2, scale_f: float, title: String, desc: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("InteriorCraft: missing prop %s" % path)
		return
	var tex := load(path) as Texture2D
	if tex == null:
		return
	var hs := _make_hotspot(parent, title, desc, pos, Vector2(56, 48))
	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.22)
	shadow.polygon = PackedVector2Array([
		Vector2(-14, 0), Vector2(0, -5), Vector2(14, 0), Vector2(0, 5),
	])
	shadow.position = Vector2(0, 10)
	shadow.z_index = -1
	hs.get_node("Visual").add_child(shadow)
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.position = Vector2(0, -float(tex.get_height()) * scale_f * 0.35)
	spr.scale = Vector2(scale_f, scale_f)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 2
	hs.get_node("Visual").add_child(spr)


func _spawn_fx(parent: Node2D) -> void:
	var fx_list: Array = _profile.get("fx", [])
	for fx in fx_list:
		var kind := str(fx.get("kind", ""))
		var tx := int(fx.get("tx", 0))
		var ty := int(fx.get("ty", 0))
		var pos := _tile_center(tx, ty) + Vector2(float(fx.get("ox", 0)), float(fx.get("oy", -8)))
		match kind:
			"fire":
				_spawn_anim_fx(parent, "fire", pos, 6.0)
				_add_point_light(parent, pos + Vector2(0, -6), Color(1.0, 0.55, 0.25), 1.25, 2.4)
			"forge":
				_spawn_anim_fx(parent, "forge", pos, 8.0)
				_add_point_light(parent, pos + Vector2(0, -4), Color(1.0, 0.45, 0.2), 1.45, 2.6)
			_:
				pass


func _spawn_anim_fx(parent: Node2D, prefix: String, pos: Vector2, fps: float) -> void:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("loop")
	frames.set_animation_speed("loop", fps)
	frames.set_animation_loop("loop", true)
	var n := 0
	for i in range(4):
		var path := "%s/%s_%02d.png" % [FX_DIR, prefix, i]
		if not ResourceLoader.exists(path):
			continue
		frames.add_frame("loop", load(path) as Texture2D)
		n += 1
	if n == 0:
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "FX_%s" % prefix
	anim.sprite_frames = frames
	anim.position = pos
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 6
	anim.play("loop")
	parent.add_child(anim)


func _spawn_ambient(parent: Node2D) -> void:
	var list: Array = _profile.get("ambient", [])
	for a in list:
		var species := str(a.get("species", ""))
		if species.is_empty():
			continue
		var critter := AmbientCritter.new()
		parent.add_child(critter)
		# craft=null → free roam inside room (no outdoor water mask).
		critter.setup(species, _tile_center(int(a.get("tx", 0)), int(a.get("ty", 0))), null, -1.0)


func _spawn_local_lights(parent: Node2D) -> void:
	var mod := CanvasModulate.new()
	mod.name = "InteriorModulate"
	mod.color = _profile.get("modulate", Color(0.82, 0.78, 0.72, 1.0))
	parent.add_child(mod)
	var lights: Array = _profile.get("lights", [])
	for L in lights:
		var pos := _tile_center(int(L.get("tx", 0)), int(L.get("ty", 0))) + Vector2(0, float(L.get("oy", 0)))
		_add_point_light(
			parent,
			pos,
			L.get("color", Color(1.0, 0.85, 0.55)),
			float(L.get("energy", 1.0)),
			float(L.get("scale", 2.0)),
		)


func _add_point_light(parent: Node2D, pos: Vector2, color: Color, energy: float, tex_scale: float) -> void:
	var light := PointLight2D.new()
	light.position = pos
	light.color = color
	light.energy = energy
	light.texture_scale = tex_scale
	light.texture = _radial_light_texture()
	light.z_index = 8
	parent.add_child(light)


func _radial_light_texture() -> GradientTexture2D:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 192
	tex.height = 192
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	return tex


func _spawn_actor(parent: Node2D) -> void:
	var a: Dictionary = _profile.get("actor", {})
	if a.is_empty():
		return
	var route: Array[Vector2] = []
	for pt in a.get("route", []):
		route.append(_tile_center(int(pt[0]), int(pt[1])))
	if route.size() < 2:
		return
	var actor := PatrolActor.new()
	parent.add_child(actor)
	actor.setup(str(a.get("id", "farmer")), str(a.get("title", "居民")), str(a.get("desc", "")), route, null)


func _spawn_return_portal(parent: Node2D) -> void:
	var portal := Area2D.new()
	portal.name = "Portal_Return"
	portal.position = _tile_center(int((_door_tx0 + _door_tx1) * 0.5), _room_h - 1) + Vector2(0, 28)
	portal.input_pickable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(128, 56)
	shape.shape = rect
	portal.add_child(shape)
	var marker := Polygon2D.new()
	marker.color = Color(0.95, 0.72, 0.28, 0.75)
	marker.polygon = PackedVector2Array([Vector2(0, -8), Vector2(10, 0), Vector2(0, 8), Vector2(-10, 0)])
	marker.position = Vector2(0, -18)
	portal.add_child(marker)
	var label := Label.new()
	label.text = "← 返回"
	label.position = Vector2(-64, -44)
	label.size = Vector2(128, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#fff4c7"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portal.add_child(label)
	portal.set_meta("scene_path", str(_profile.get("return_path", SceneRouter.RESIDENTIAL_PATH)))
	parent.add_child(portal)


func _apply_topbar_hint(root: Node2D) -> void:
	var hint := root.get_node_or_null("UI/TopBar/Hint") as Label
	if hint:
		hint.text = str(_profile.get("hint", _profile.get("title", "室内")))


func _make_hotspot(parent: Node2D, title: String, desc: String, pos: Vector2, size: Vector2) -> InteractableHotspot:
	var hs := InteractableHotspot.new()
	hs.name = title.replace(" ", "")
	hs.title = title
	hs.description = desc
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
	return hs
