class_name FarmResidentialAssembler
extends Node

## Farm residential (A02) — AreaCraft masks + layered assemble.
## Pass: masks → ecology → dirt → water → path → buildings → props → trees → actors → FX.
## Facing: south-door farmhouse north of yard path. No animals in pond.

const MAP_W := 40
const MAP_H := 30

## Pond oval center (tile coords) — SE yard, meander/soft edge.
const POND_CX := 31.2
const POND_CY := 22.6
const POND_RX := 4.2
const POND_RY := 3.1

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

	_spawn_buildings(ysort)
	_spawn_props(ysort)
	_spawn_fences(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_pond_tile(x, y)

	_paint_dirt_network()
	_paint_garden_beds()
	_paint_stone_approach()
	# Paths / dirt / gardens clear water (pond stays SE; beds never become water).
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _compute_pond_tile(tx: int, ty: int) -> bool:
	# Soft oval + cove noise (skill meander style, localized pond).
	var nx: float = (float(tx) - POND_CX) / POND_RX
	var ny: float = (float(ty) - POND_CY) / POND_RY
	var d2: float = nx * nx + ny * ny
	if d2 <= 1.0:
		return true
	# Soft cove / irregular shoreline — not a Rect2i.
	var wobble: float = 0.18 * sin(float(tx) * 0.9 + float(ty) * 0.55) + 0.12 * cos(float(ty) * 1.1 + 0.4)
	if d2 <= 1.0 + wobble and sin(float(tx) * 0.7 + float(ty) * 1.3) > 0.15:
		return true
	return false


func _set_dirt(tx: int, ty: int, force: bool = false) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if craft.is_water(tx, ty) and not force:
		return
	if force:
		craft.water_mask[ty][tx] = false
	craft.dirt_mask[ty][tx] = true
	craft.path_mask[ty][tx] = false


func _set_path(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if craft.is_water(tx, ty):
		return
	craft.path_mask[ty][tx] = true
	craft.dirt_mask[ty][tx] = false


func _fill_dirt_rect(x0: int, y0: int, x1: int, y1: int, force: bool = false) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_dirt(tx, ty, force)


func _paint_dirt_network() -> void:
	# Horizontal building lane in front of coop / farmhouse / barn (door aprons face south).
	_fill_dirt_rect(5, 8, 34, 9)
	# Farmhouse door spur (south of house footprint into yard).
	_fill_dirt_rect(18, 7, 21, 11)
	# Central yard spine toward gardens.
	_fill_dirt_rect(18, 10, 21, 20)
	# Coop run / approach from lane.
	_fill_dirt_rect(5, 7, 10, 9)
	_fill_dirt_rect(6, 9, 8, 11)
	# Barn approach.
	_fill_dirt_rect(28, 7, 34, 9)
	_fill_dirt_rect(30, 9, 33, 11)
	# Cross lanes between garden beds.
	_fill_dirt_rect(5, 17, 34, 18)
	_fill_dirt_rect(11, 12, 12, 17)
	_fill_dirt_rect(17, 12, 18, 17)
	_fill_dirt_rect(26, 12, 27, 17)
	# Pond approach (dirt to north bank — no animals in water).
	_fill_dirt_rect(22, 19, 28, 20)
	_fill_dirt_rect(27, 18, 29, 21)
	# Dock stub on north bank (force land apron over soft pond edge).
	_fill_dirt_rect(29, 19, 32, 19, true)


func _paint_garden_beds() -> void:
	# Crop-adjacent dirt patches (garden beds) — dirt_mask rows, never water.
	# West bed.
	_fill_dirt_rect(5, 12, 10, 16)
	# Center-west bed.
	_fill_dirt_rect(13, 12, 16, 16)
	# Center-east bed (sunflower strip zone).
	_fill_dirt_rect(22, 12, 25, 16)
	# East raised planter strip.
	_fill_dirt_rect(28, 12, 32, 15)
	# Restore walk lanes that beds would have filled (beds sit beside paths).
	_fill_dirt_rect(11, 12, 12, 17)
	_fill_dirt_rect(17, 12, 18, 17)
	_fill_dirt_rect(18, 12, 21, 18)
	_fill_dirt_rect(26, 12, 27, 17)
	_fill_dirt_rect(5, 17, 34, 18)


func _paint_stone_approach() -> void:
	# Short stone approach from south edge portal into dirt spine.
	for ty in range(24, 29):
		for tx in range(18, 22):
			_set_path(tx, ty)
	# Soft merge onto dirt spine.
	for tx in range(18, 22):
		_set_dirt(tx, 21)
		_set_dirt(tx, 22)
		_set_dirt(tx, 23)


func _spawn_buildings(ysort: Node2D) -> void:
	# South-facing art → lots north of yard path; doors toward yard.
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(640, 150),
			"hw": 3, "hh": 2,
			"title": "农舍",
			"desc": "农场主宅：门脸朝南，门前土路通向院落与菜畦。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(240, 150),
			"hw": 2, "hh": 2,
			"title": "鸡舍",
			"desc": "西北鸡舍与围栏区；门朝南接土路（不下水塘）。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(1020, 150),
			"hw": 3, "hh": 2,
			"title": "谷仓",
			"desc": "东北谷仓位，门朝南，土路接农舍前廊。",
		},
	]
	for s in specs:
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, int(s["hw"]), int(s["hh"]), 10, false)
		if cleared == Vector2.ZERO:
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(36, 12))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	# Crates / sacks / barrels on plantable grass near beds & house (footprint_ok).
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(420, 280), "title": "货箱", "desc": "菜畦旁货箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_1.png", "pos": Vector2(860, 280), "title": "木箱", "desc": "东畦旁木箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(540, 260), "title": "麻袋", "desc": "农舍前草皮麻袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(700, 300), "title": "粮袋", "desc": "院落粮袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(300, 300), "title": "木桶", "desc": "鸡舍旁木桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(1080, 300), "title": "水桶", "desc": "谷仓旁水桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(580, 360), "title": "院灯", "desc": "院落路灯。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/B11-06_mailbox_board_00.png", "pos": Vector2(760, 620), "title": "路牌", "desc": "通向水塘的岔路标识。", "hw": 1, "hh": 1},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, false)
		if cleared == Vector2.ZERO:
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_fences(ysort: Node2D) -> void:
	# Post-and-rail proxies along west garden + outer yard (no dedicated fence sheet).
	var segments: Array[Dictionary] = [
		{"origin": Vector2(160, 380), "count": 6, "step": Vector2(32, 0), "title": "西畦围栏"},
		{"origin": Vector2(160, 380), "count": 5, "step": Vector2(0, 32), "title": "西畦侧栏"},
		{"origin": Vector2(160, 520), "count": 6, "step": Vector2(32, 0), "title": "西畦南栏"},
		{"origin": Vector2(200, 200), "count": 4, "step": Vector2(28, 0), "title": "鸡舍围栏"},
	]
	for seg in segments:
		var origin: Vector2 = seg["origin"]
		var step: Vector2 = seg["step"]
		var count: int = int(seg["count"])
		for i in range(count):
			var ideal: Vector2 = origin + step * float(i)
			var pos := craft.find_clear_near(ideal, 0, 0, 4, false)
			if pos == Vector2.ZERO:
				continue
			var post := ColorRect.new()
			post.size = Vector2(8, 22)
			post.position = Vector2(-4, -18)
			post.color = Color(0.42, 0.28, 0.14, 0.85)
			var hs := craft.make_hotspot(ysort, str(seg["title"]), "木围栏，围住菜畦/鸡舍跑场。", pos, Vector2(24, 32))
			hs.get_node("Visual").add_child(post)
			# Rail between posts.
			if i < count - 1:
				var rail := ColorRect.new()
				rail.size = Vector2(maxi(4, int(step.length()) - 4), 3)
				rail.position = Vector2(2, -12)
				rail.color = Color(0.5, 0.34, 0.18, 0.7)
				hs.get_node("Visual").add_child(rail)


func _spawn_trees(ysort: Node2D) -> void:
	# Forest ring + a few orchard trees on plantable only (never water / walks).
	var ideals := [
		Vector2(80, 80), Vector2(160, 60), Vector2(80, 400), Vector2(60, 700),
		Vector2(1200, 80), Vector2(1180, 360), Vector2(1200, 700), Vector2(1000, 820),
		Vector2(200, 820), Vector2(400, 860), Vector2(700, 880), Vector2(900, 100),
		Vector2(1120, 520), Vector2(100, 520), Vector2(480, 80), Vector2(800, 60),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 8, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y) or craft.is_bank(t.x, t.y):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(22, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)


func _spawn_actors(ysort: Node2D) -> void:
	# Sparse NPC patrol on dirt / stone walks only — never into pond.
	var actors := [
		{
			"path": "res://assets/sprites/npc/npc_00.png",
			"title": "农夫",
			"desc": "沿院落土路巡视菜畦。",
			"waypoints": [
				Vector2(640, 300),
				Vector2(640, 560),
				Vector2(400, 560),
				Vector2(400, 300),
				Vector2(640, 300),
			],
		},
		{
			"path": "res://assets/sprites/npc/npc_01.png",
			"title": "帮手",
			"desc": "在农舍与谷仓前廊之间走动。",
			"waypoints": [
				Vector2(320, 280),
				Vector2(640, 280),
				Vector2(1000, 280),
				Vector2(640, 280),
			],
		},
		{
			"path": "res://assets/sprites/npc/npc_02.png",
			"title": "访客",
			"desc": "从南口石板走进院落（不下水塘）。",
			"waypoints": [
				Vector2(640, 820),
				Vector2(640, 700),
				Vector2(640, 560),
				Vector2(880, 620),
				Vector2(640, 700),
			],
		},
	]
	for a in actors:
		if not ResourceLoader.exists(a["path"]):
			continue
		var route: Array[Vector2] = craft.snap_patrol_route(a["waypoints"])
		if route.is_empty():
			continue
		var start: Vector2 = route[0]
		var hs := craft.make_hotspot(ysort, a["title"], a["desc"], start, Vector2(40, 56))
		var visual: Node2D = hs.get_node("Visual")
		craft.add_contact_shadow(visual, Vector2(0, 0), Vector2(12, 5))
		var spr := craft.spawn_sprite(visual, a["path"], Vector2.ZERO)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		craft.animate_patrol(hs, route)


func _spawn_portals(ysort: Node2D) -> void:
	# Edge portals — top bar also mirrors these; keep scene ring connected.
	craft.make_portal(
		ysort,
		"→住宅区",
		SceneRouter.RESIDENTIAL_PATH,
		Vector2(80, 480),
		Vector2(96, 56)
	)
	craft.make_portal(
		ysort,
		"→广场",
		SceneRouter.SQUARE_PATH,
		Vector2(1200, 480),
		Vector2(96, 56)
	)
	craft.make_portal(
		ysort,
		"→总览",
		SceneRouter.HUB_PATH,
		Vector2(640, 40),
		Vector2(96, 48)
	)
