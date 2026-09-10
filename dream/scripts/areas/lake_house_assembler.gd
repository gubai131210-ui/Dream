class_name LakeHouseAssembler
extends Node

## Lake house (A15) — single lakeside dwelling + dock spur. Intimate, not a plaza.

const MAP_W := 40
const MAP_H := 30

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H)
	_rebuild_masks()
	craft.prepare_layers(ground, path, water)
	craft.paint_ecological_grass(ground)
	craft.paint_dirt_spurs(ground)
	craft.paint_water(water, ground)
	craft.paint_paths(path)
	_spawn_house(ysort)
	_spawn_dock(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _cove_water(x, y)
	_paint_yard_and_dock()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_dirt(x, y) or craft.is_path(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _cove_water(tx: int, ty: int) -> bool:
	# West/south cove — house sits on NE dry lobe.
	var cx := 12.0 + sin(float(ty) * 0.3) * 2.0
	var cy := 18.0
	var rx := 12.0
	var ry := 9.0
	var nx := (float(tx) - cx) / rx
	var ny := (float(ty) - cy) / ry
	if nx * nx + ny * ny <= 1.0:
		return true
	if tx < 8 and ty > 10:
		return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.dirt_mask[ty][tx] = true
	craft.water_mask[ty][tx] = false


func _paint_yard_and_dock() -> void:
	# House yard pad.
	for ty in range(8, 16):
		for tx in range(22, 32):
			_set_dirt(tx, ty)
	# Door dirt south of house.
	for tx in range(24, 30):
		_set_dirt(tx, 15)
		_set_dirt(tx, 16)
	# Dock spur into water (west).
	for tx in range(10, 24):
		_set_dirt(tx, 17)
		_set_dirt(tx, 18)
	# Path toward lake (east/north).
	for ty in range(2, 10):
		_set_dirt(26, ty)
		_set_dirt(27, ty)


func _spawn_house(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(1.5)
	var path := "res://assets/sprites/buildings/building_01.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_02.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	var offset := craft.building_offset_for(tex)
	var ideal := Vector2(860, 360)
	var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 16, true)
	if cleared == Vector2.ZERO:
		return
	craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
	var spr := craft.spawn_sprite(ysort, path, cleared)
	spr.offset = offset


func _spawn_dock(ysort: Node2D) -> void:
	var dock := ColorRect.new()
	dock.name = "DockPlanks"
	dock.color = Color(0.55, 0.4, 0.28, 0.85)
	dock.size = Vector2(280, 36)
	dock.position = Vector2(320, 530)
	dock.z_index = 2
	ysort.add_child(dock)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(700, 520), "title": "码头桶", "desc": "小屋码头旁的桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(920, 500), "title": "门前箱", "desc": "湖畔小屋门边木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(820, 560), "title": "廊灯", "desc": "通向码头的小灯。"},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		if s.has("scale"):
			spr.scale = Vector2(float(s["scale"]), float(s["scale"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var ideals: Array[Vector2] = [
		Vector2(1100, 120), Vector2(1180, 360), Vector2(1140, 700),
		Vector2(980, 100), Vector2(760, 120), Vector2(700, 780),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 4, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(18, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "elder_woman", "湖居者", "在小屋门前与码头之间走动。",
		[Vector2(860, 500), Vector2(720, 540), Vector2(520, 540), Vector2(860, 520)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(640, 60), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(1200, 200), Vector2(96, 48))
