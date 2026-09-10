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

	craft.setup(MAP_W, MAP_H, "wild")
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
	var zone := craft.map_play_rect(2.0)
	var path := "res://assets/sprites/buildings/dock_house_00.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_01.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_02.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	var offset := craft.building_offset_for(tex)
	var ideal := Vector2(820, 420)
	var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 18, true)
	if cleared == Vector2.ZERO:
		# Oversized dock sheet — scale down.
		cleared = ideal
		craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
		var spr2 := craft.spawn_sprite(ysort, path, cleared)
		spr2.offset = offset
		spr2.scale = Vector2(0.55, 0.55)
		craft.make_hotspot(ysort, "湖畔小屋", "建在木桩码头上的湖居。", cleared + Vector2(0, 24), Vector2(120, 80))
		return
	craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
	var spr := craft.spawn_sprite(ysort, path, cleared)
	spr.offset = offset
	if float(tex.get_height()) > 400.0 or float(tex.get_width()) > 400.0:
		spr.scale = Vector2(0.58, 0.58)
	craft.make_hotspot(ysort, "湖畔小屋", "建在木桩码头上的湖居。", cleared + Vector2(0, 24), Vector2(120, 80))


func _spawn_dock(ysort: Node2D) -> void:
	# Dock reads from dirt spur + house art — no opaque ColorRect plank slab.
	# Optional barrel markers along the spur only.
	var marks := [Vector2(420, 560), Vector2(500, 560)]
	for i in marks.size():
		var path := "res://assets/sprites/props/barrel_%d.png" % (i % 3)
		if not ResourceLoader.exists(path):
			continue
		var pos: Vector2 = marks[i]
		var cleared := craft.find_clear_near(pos, 1, 1, 4, true)
		if cleared == Vector2.ZERO:
			continue
		craft.add_contact_shadow(ysort, cleared, Vector2(10, 4))
		var spr := craft.spawn_sprite(ysort, path, cleared)
		spr.scale = Vector2(0.45, 0.45)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(700, 520), "title": "码头桶", "desc": "小屋码头旁的桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(920, 500), "title": "门前箱", "desc": "湖畔小屋门边木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(820, 560), "title": "廊灯", "desc": "通向码头的小灯。", "scale": 0.55},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.scale = Vector2(float(s.get("scale", 0.55)), float(s.get("scale", 0.55)))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = [
		Vector2(1040, 280), Vector2(1100, 480), Vector2(1080, 720),
		Vector2(900, 240), Vector2(720, 760),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 6, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "elder_woman", "湖居者", "在小屋门前与码头之间走动。",
		[Vector2(860, 500), Vector2(720, 540), Vector2(520, 540), Vector2(860, 520)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(640, 60), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(1200, 200), Vector2(96, 48))
