class_name LakeHouseAssembler
extends Node

## Lake house (A15) — single lakeside dwelling + dock spur. Intimate, not a plaza.
## Dock = dirt spur + props / dock_house_00 only — never ColorRect planks.

const MAP_W := 40
const MAP_H := 30
const BUILD_Y := 0.35
const TREE_Y := 0.40

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
	_spawn_dock_props(ysort)
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
	# Dock spur into water (west) — visual dock without ColorRect.
	for tx in range(10, 24):
		_set_dirt(tx, 17)
		_set_dirt(tx, 18)
	# Path toward lake (east/north).
	for ty in range(2, 10):
		_set_dirt(26, ty)
		_set_dirt(27, ty)


func _scaled_fully_inside(pos: Vector2, tex: Texture2D, y_factor: float, scale_f: float, zone: Rect2) -> bool:
	var size := Vector2(float(tex.get_width()), float(tex.get_height())) * scale_f
	var offset := Vector2(0.0, -float(tex.get_height()) * y_factor) * scale_f
	var top_left := pos + offset - size * 0.5
	var r := Rect2(top_left, size)
	return (
		r.position.x >= zone.position.x
		and r.position.y >= zone.position.y
		and r.end.x <= zone.end.x
		and r.end.y <= zone.end.y
	)


func _find_scaled_inside(
	ideal: Vector2,
	tex: Texture2D,
	y_factor: float,
	scale_f: float,
	zone: Rect2,
	half_w: int,
	half_h: int,
	max_r: int,
	allow_path: bool
) -> Vector2:
	if craft.footprint_ok(ideal, half_w, half_h, allow_path) and _scaled_fully_inside(ideal, tex, y_factor, scale_f, zone):
		return ideal
	var t := craft.world_to_tile(ideal)
	for r in range(0, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if r > 0 and maxi(absi(ox), absi(oy)) != r:
					continue
				var cand := craft.tile_center(t.x + ox, t.y + oy)
				if not craft.footprint_ok(cand, half_w, half_h, allow_path):
					continue
				if _scaled_fully_inside(cand, tex, y_factor, scale_f, zone):
					return cand
	return Vector2.ZERO


func _spawn_house(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(1.5)
	var path := "res://assets/sprites/buildings/dock_house_00.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_01.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_02.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	if tex == null:
		return
	var offset := craft.building_offset_for(tex)
	# South enough that tall dock_house AABB clears north play margin.
	var ideal := Vector2(860, 480)
	var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 18, true)
	var scale_f := 1.0
	if cleared == Vector2.ZERO:
		# Oversized sheet (dock_house ~575×485): scale down, keep full AABB ⊆ zone.
		for s in [0.7, 0.55, 0.45]:
			cleared = _find_scaled_inside(ideal, tex, BUILD_Y, s, zone, 2, 1, 20, true)
			if cleared != Vector2.ZERO:
				offset = craft.building_offset_for(tex)
				scale_f = s
				break
	if cleared == Vector2.ZERO:
		push_warning("LakeHouse: could not place house fully inside play zone")
		return
	craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
	var spr := craft.spawn_sprite(ysort, path, cleared)
	spr.offset = offset
	if scale_f < 0.999:
		spr.scale = Vector2(scale_f, scale_f)
	craft.make_hotspot(ysort, "湖畔小屋", "临湖木屋，西侧土径伸入浅湾。", cleared + Vector2(0, 24), Vector2(110, 80))


func _spawn_dock_props(ysort: Node2D) -> void:
	# Dock read from dirt spur + end props — no ColorRect deck.
	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(400, 560), "title": "系缆桶", "desc": "码头尽头的系缆空桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(480, 548), "title": "卸货箱", "desc": "小舟卸货用的木箱。", "scale": 0.52},
		{"path": "res://assets/sprites/props/rock_02.png", "pos": Vector2(360, 580), "title": "岸石", "desc": "码头旁的浅滩石。", "scale": 0.38},
	]
	for s in samples:
		_place_land_prop(ysort, s)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(520, 560), "title": "码头桶", "desc": "小屋码头旁的桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(920, 500), "title": "门前箱", "desc": "湖畔小屋门边木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(820, 560), "title": "廊灯", "desc": "通向码头的小灯。", "scale": 0.55},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(700, 520), "title": "渔网袋", "desc": "码头边晒干的网袋。", "scale": 0.5},
	]
	for s in samples:
		_place_land_prop(ysort, s)


func _place_land_prop(ysort: Node2D, s: Dictionary) -> void:
	if not ResourceLoader.exists(s["path"]):
		return
	var pos: Vector2 = s["pos"]
	var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
	if cleared != Vector2.ZERO:
		pos = cleared
	var t := craft.world_to_tile(pos)
	if craft.is_water(t.x, t.y):
		return
	craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
	var spr := craft.spawn_sprite(ysort, s["path"], pos)
	var sc := float(s.get("scale", 0.55))
	spr.scale = Vector2(sc, sc)
	var title := str(s.get("title", ""))
	if title != "":
		var hs := craft.make_hotspot(ysort, title, str(s.get("desc", "")), pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = [
		Vector2(1080, 200), Vector2(1140, 400), Vector2(1100, 720),
		Vector2(940, 180), Vector2(720, 200), Vector2(680, 780),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 5, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "elder_woman", "湖居者", "在小屋门前与码头之间走动。",
		[Vector2(860, 500), Vector2(720, 540), Vector2(520, 540), Vector2(860, 520)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(640, 60), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(1200, 200), Vector2(96, 48))
