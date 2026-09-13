class_name ForestEntranceAssembler
extends Node

## Forest entrance (A04) — dense edge trees + dirt trail spine + small clearing.
## Silhouette: tree mass + narrow trail (NOT a stone plaza). Optional cabin fully inside play zone.

const MAP_W := 40
const MAP_H := 30

## Central clearing (grass / light dirt) — keep small.
const CLEAR_TX0 := 14
const CLEAR_TX1 := 25
const CLEAR_TY0 := 11
const CLEAR_TY1 := 18

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

	_spawn_cabin(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_brook_tile(x, y)
	_paint_dirt_trail()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _brook_cx(ty: float) -> float:
	return 6.2 + sin(ty * 0.38) * 1.4 + cos(ty * 0.21 + 0.5) * 0.7


func _brook_hw(ty: float) -> float:
	return 1.2 + 0.35 * sin(ty * 0.5 + 0.3)


func _compute_brook_tile(tx: int, ty: int) -> bool:
	# Tiny west brook — not a plaza river wall.
	if ty < 8 or ty > 22:
		return false
	if tx > 10:
		return false
	var cx := _brook_cx(float(ty))
	var hw := _brook_hw(float(ty))
	var dx := absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 0.7 and sin(float(ty) * 0.8 + float(tx)) > 0.6:
		return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if craft.is_water(tx, ty):
		return
	craft.dirt_mask[ty][tx] = true
	craft.path_mask[ty][tx] = false


func _fill_dirt(x0: int, y0: int, x1: int, y1: int) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_dirt(tx, ty)


func _paint_dirt_trail() -> void:
	# N–S dirt spine through clearing (narrow — silhouette vs plaza).
	_fill_dirt(19, 4, 21, 26)
	# E–W spur across clearing.
	_fill_dirt(12, 14, 28, 15)
	# Soft clearing apron (dirt pockets, not stone).
	_fill_dirt(CLEAR_TX0, CLEAR_TY0, CLEAR_TX0 + 2, CLEAR_TY1)
	_fill_dirt(CLEAR_TX1 - 2, CLEAR_TY0, CLEAR_TX1, CLEAR_TY1)
	# Door apron south of cabin foot (~ty 10).
	_fill_dirt(18, 11, 22, 12)
	# Short dirt bridge over brook at mid trail.
	for ty in [14, 15]:
		for tx in range(4, 10):
			craft.dirt_mask[ty][tx] = true
			craft.water_mask[ty][tx] = false


func _spawn_cabin(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(1.5)
	var path := "res://assets/sprites/buildings/building_02.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	var offset := craft.building_offset_for(tex)
	var ideal := Vector2(640, 320)
	var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 16, true)
	if cleared == Vector2.ZERO:
		push_warning("ForestEntrance: cabin could not fit play zone")
		return
	craft.add_contact_shadow(ysort, cleared, Vector2(32, 11))
	var spr := craft.spawn_sprite(ysort, path, cleared)
	spr.offset = offset
	craft.mark_blocked_footprint(cleared, 2, 1)
	var hs := craft.make_hotspot(ysort, "林缘小屋", "森林入口空地旁小屋：整栋在 play zone 内。", cleared + Vector2(0, 20), Vector2(100, 72))
	spr.reparent(hs.get_node("Visual"))
	spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	# Lamp/bench sit south of cabin door apron (ty 11–12) so clearing stays wild, not residential.
	var samples := [
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(560, 540), "title": "林径灯", "desc": "土径旁路灯。"},
		{"path": "res://assets/sprites/props/bench_2.png", "pos": Vector2(520, 580), "title": "歇脚木凳", "desc": "空地木凳（林缘款）。"},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(700, 400), "title": "行囊", "desc": "小屋旁行囊。", "scale": 0.55},
		{"path": "res://assets/sprites/props/crate_1.png", "pos": Vector2(500, 400), "title": "木箱", "desc": "林缘补给箱。", "scale": 0.55},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
		if cleared == Vector2.ZERO:
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
		else:
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var sc := float(s.get("scale", 0.55))
		if sc > 0.55:
			sc = 0.55
		spr.scale = Vector2(sc, sc)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
	_spawn_brook_rocks(ysort)


func _spawn_brook_rocks(ysort: Node2D) -> void:
	# West brook bank accents — river_bank / forest_moss at shore height.
	var rocks := [
		{"family": RockCatalog.FAMILY_RIVER_BANK, "i": 0, "pos": Vector2(200, 420)},
		{"family": RockCatalog.FAMILY_FOREST_MOSS, "i": 2, "pos": Vector2(180, 520)},
	]
	for r in rocks:
		var path := RockCatalog.path(str(r["family"]), int(r["i"]))
		if not ResourceLoader.exists(path):
			continue
		var tex := RockCatalog.load_tex(str(r["family"]), int(r["i"]))
		var pos: Vector2 = r["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 4, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y) or craft.is_dirt(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(10, 4))
		var spr := craft.spawn_sprite(ysort, path, pos)
		var sc := RockCatalog.scale_for_target_h(tex, RockCatalog.TARGET_H_SHORE) if tex else 0.3
		sc = clampf(sc, 0.22, 0.4)
		spr.scale = Vector2(sc, sc)


func _spawn_trees(ysort: Node2D) -> void:
	# Dense forest belt OUTSIDE / around clearing — full crown AABB via spawn_tree.
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = []
	for i in range(28):
		var ang := float(i) * 0.45
		var r := 380.0 + float(i % 5) * 40.0
		ideals.append(Vector2(640, 480) + Vector2(cos(ang), sin(ang)) * r)
	# Edge fills inset enough that crowns fit play zone (no north-rim half-trees).
	# Former (640,180) sat due-north of cabin (640,320) and pierced its AABB — NW instead.
	ideals.append_array([
		Vector2(140, 200), Vector2(200, 160), Vector2(120, 400), Vector2(140, 700),
		Vector2(1120, 180), Vector2(1160, 400), Vector2(1140, 700),
		Vector2(400, 160), Vector2(800, 160), Vector2(520, 140),
		Vector2(300, 800), Vector2(700, 820), Vector2(1000, 800),
		Vector2(100, 560), Vector2(1180, 560),
	])
	var placed := 0
	for i in ideals.size():
		var ideal: Vector2 = ideals[i]
		var t0 := craft.world_to_tile(ideal)
		if craft.is_water(t0.x, t0.y) or craft.is_dirt(t0.x, t0.y):
			continue
		# Keep trail + clearing visually open.
		if t0.x >= CLEAR_TX0 and t0.x <= CLEAR_TX1 and t0.y >= CLEAR_TY0 and t0.y <= CLEAR_TY1:
			continue
		# Trail spine + cabin column (cabin foot ~ty 10; skip north to ty 4 so crowns can't slide into roof).
		if t0.x >= 17 and t0.x <= 23 and t0.y >= 4 and t0.y <= 24:
			continue
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideal, zone, 1, 1, 6, false)
		if spr == null:
			continue
		spr.flip_h = (i % 2 == 0)
		placed += 1
	if placed < 16:
		push_warning("ForestEntrance: sparse tree spawn (%d) — check tree assets / AABB zone" % placed)


func _spawn_actors(ysort: Node2D) -> void:
	var actors := [
		{
			"id": "farmer",
			"title": "采蘑菇的人",
			"desc": "沿林径土路在空地与南口之间走动。",
			"waypoints": [
				Vector2(640, 480),
				Vector2(640, 640),
				Vector2(560, 520),
				Vector2(720, 520),
				Vector2(640, 480),
			],
		},
		{
			"id": "elder_woman",
			"title": "散步村民",
			"desc": "从住宅方向走进森林入口空地。",
			"waypoints": [
				Vector2(640, 200),
				Vector2(640, 360),
				Vector2(560, 480),
				Vector2(720, 480),
				Vector2(640, 360),
			],
		},
	]
	for a in actors:
		craft.spawn_patrol_actor(ysort, a["id"], a["title"], a["desc"], a["waypoints"])


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→住宅区", SceneRouter.RESIDENTIAL_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→深林", SceneRouter.FOREST_DEEP_PATH, Vector2(640, 120), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
