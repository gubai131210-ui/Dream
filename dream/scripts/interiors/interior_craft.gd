class_name InteriorCraft
extends Node

## Interior foundation-first assembler (PHASE5 / PROP_ORIENTATION / SCALE).
## Pass order: floor → walls/door/window → rug → furniture (outdoor props) → local warm lights → actor → portal.
## 32px grid. No checkerboard ColorRect floors. No full-room orange wash.

const TILE := 32
const ORIGIN := Vector2i(4, 4) ## top-left of playable room in tiles
const ROOM_W := 32 ## tiles
const ROOM_H := 20 ## tiles
## Circulation: south door → center aisle clear of furniture.
const DOOR_TX0 := 14
const DOOR_TX1 := 17
const WALL_THICK := 2 ## north wall depth in tiles (upper plaster + lower wainscot)

const TILE_DIR := "res://assets/sprites/interior/tiles"
const PROP_SCALE := 0.55


func assemble(root: Node2D) -> void:
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
	_spawn_local_lights(world)
	_spawn_actor(world)
	_spawn_return_portal(world)


func room_rect() -> Rect2:
	return Rect2(
		float(ORIGIN.x * TILE),
		float(ORIGIN.y * TILE),
		float(ROOM_W * TILE),
		float(ROOM_H * TILE),
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


func _paint_floor(parent: Node2D) -> void:
	for ty in range(WALL_THICK, ROOM_H):
		for tx in range(ROOM_W):
			var path := "%s/floor_%02d.png" % [TILE_DIR, (tx + ty * 3) % 4]
			_spawn_tile(parent, path, tx, ty, -5)


func _paint_walls(parent: Node2D) -> void:
	# North wall: upper plaster (ty0) + lower wainscot (ty1).
	for tx in range(ROOM_W):
		_spawn_tile(parent, "%s/wall_upper_%02d.png" % [TILE_DIR, tx % 4], tx, 0, -2)
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, tx % 4], tx, 1, -1)
	# Side posts / pillars at corners and mid.
	for tx in [0, 10, 21, ROOM_W - 1]:
		_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, tx, 0, 0)
		_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, tx, 1, 0)
	# East / west thin wall columns down the room edges (wainscot feel).
	for ty in range(WALL_THICK, ROOM_H):
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, ty % 4], 0, ty, -1)
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, (ty + 1) % 4], ROOM_W - 1, ty, -1)


func _paint_door_and_window(parent: Node2D) -> void:
	# South doorway: clear floor already; stone steps + posts.
	for tx in range(DOOR_TX0, DOOR_TX1 + 1):
		_spawn_tile(parent, "%s/doorstep_00.png" % TILE_DIR, tx, ROOM_H - 1, 1)
	_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, DOOR_TX0 - 1, ROOM_H - 1, 2)
	_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, DOOR_TX1 + 1, ROOM_H - 1, 2)
	var door_frame := "%s/door_frame_00.png" % TILE_DIR
	if ResourceLoader.exists(door_frame):
		for tx in [DOOR_TX0 - 1, DOOR_TX1 + 1]:
			var spr := Sprite2D.new()
			spr.texture = load(door_frame) as Texture2D
			spr.centered = true
			spr.position = _tile_center(tx, ROOM_H - 2)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.z_index = 2
			parent.add_child(spr)
	# North window over center wall.
	var win_path := "%s/window_00.png" % TILE_DIR
	if ResourceLoader.exists(win_path):
		var spr := Sprite2D.new()
		spr.texture = load(win_path) as Texture2D
		spr.centered = true
		spr.position = _tile_center(15, 0) + Vector2(16, 16)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 3
		parent.add_child(spr)
	# Soft painted window shaft (local, not full-room orange).
	var shaft := Polygon2D.new()
	shaft.name = "WindowLightShaft"
	shaft.color = Color(1.0, 0.92, 0.65, 0.14)
	shaft.polygon = PackedVector2Array([
		_tile_center(13, 2) + Vector2(-20, -10),
		_tile_center(18, 2) + Vector2(20, -10),
		_tile_center(19, 8) + Vector2(10, 0),
		_tile_center(12, 8) + Vector2(-10, 0),
	])
	shaft.z_index = -3
	parent.add_child(shaft)


func _paint_rug(parent: Node2D) -> void:
	# Entry rug on circulation (south of center).
	var ox := 14
	var oy := 12
	for qy in range(2):
		for qx in range(2):
			_spawn_tile(parent, "%s/rug_%d_%d.png" % [TILE_DIR, qy, qx], ox + qx, oy + qy, 0)


func _spawn_zone_labels(_parent: Node2D) -> void:
	pass


func _spawn_furniture(parent: Node2D) -> void:
	# Zones: window dining (N) → storage (E) → sleep (SE). Keep center aisle + door clear.
	_spawn_prop(parent, "res://assets/sprites/props/bench_0.png", _tile_center(10, 6), PROP_SCALE, "木桌", "北窗下的用餐木桌。")
	_spawn_prop(parent, "res://assets/sprites/props/bench_1.png", _tile_center(10, 8), PROP_SCALE, "长椅", "桌旁歇脚长椅。")
	_spawn_prop(parent, "res://assets/sprites/props/crate_0.png", _tile_center(27, 7), PROP_SCALE, "储物箱", "东墙储物木箱。")
	_spawn_prop(parent, "res://assets/sprites/props/crate_1.png", _tile_center(27, 9), PROP_SCALE, "木箱", "叠放的日用木箱。")
	_spawn_prop(parent, "res://assets/sprites/props/barrel_1.png", _tile_center(25, 11), PROP_SCALE, "木桶", "竖放储水木桶。")
	_spawn_prop(parent, "res://assets/sprites/props/lamp_0.png", _tile_center(28, 6), PROP_SCALE, "壁灯", "东墙暖色壁灯。")
	_spawn_prop(parent, "res://assets/sprites/props/sack_0.png", _tile_center(6, 15), PROP_SCALE, "粮袋", "门厅旁粮袋。")
	_spawn_bed(parent, _tile_center(25, 15))


func _spawn_prop(parent: Node2D, path: String, pos: Vector2, scale_f: float, title: String, desc: String) -> void:
	if not ResourceLoader.exists(path):
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


func _spawn_bed(parent: Node2D, pos: Vector2) -> void:
	var path := "%s/bed_00.png" % TILE_DIR
	if ResourceLoader.exists(path):
		_spawn_prop(parent, path, pos, 1.0, "床铺", "休息区床铺，床脚留出通行。")
		return
	# Fallback: crate + sack silhouette if bed tile missing.
	_spawn_prop(parent, "res://assets/sprites/props/crate_0.png", pos, PROP_SCALE, "床铺", "临时床位（待床铺素材）。")


func _spawn_local_lights(parent: Node2D) -> void:
	# Mild CanvasModulate so PointLight2D reads; keep warm, not full orange.
	var mod := CanvasModulate.new()
	mod.name = "InteriorModulate"
	mod.color = Color(0.82, 0.78, 0.72, 1.0)
	parent.add_child(mod)
	_add_point_light(parent, _tile_center(28, 6) + Vector2(0, -20), Color(1.0, 0.85, 0.55), 1.15, 2.2)
	_add_point_light(parent, _tile_center(15, 2) + Vector2(0, 24), Color(1.0, 0.94, 0.75), 0.75, 2.8)


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
	var actor := PatrolActor.new()
	parent.add_child(actor)
	# Stay on open aisle: south of table, west of storage, north of bed.
	actor.setup(
		"farmer",
		"屋主",
		"在室内整理桌面与储物箱。",
		[
			_tile_center(12, 10),
			_tile_center(18, 10),
			_tile_center(18, 14),
			_tile_center(12, 14),
		],
		null,
	)


func _spawn_return_portal(parent: Node2D) -> void:
	var portal := Area2D.new()
	portal.name = "Portal_ReturnResidential"
	portal.position = _tile_center(int((DOOR_TX0 + DOOR_TX1) * 0.5), ROOM_H - 1) + Vector2(0, 28)
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
	label.text = "← 返回住宅区"
	label.position = Vector2(-64, -44)
	label.size = Vector2(128, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#fff4c7"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portal.add_child(label)
	portal.set_meta("scene_path", SceneRouter.RESIDENTIAL_PATH)
	parent.add_child(portal)


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
