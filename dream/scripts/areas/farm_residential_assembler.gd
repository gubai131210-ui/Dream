class_name FarmResidentialAssembler
extends Node

## Farm residential (A02) — AreaCraft masks + layered assemble.
## District: farm_home (AREA_FRAMEWORK). craft.setup(..., "farm_home").
## Buildings must sit FULLY inside the farm play zone (sprite AABB), not straddling fence/forest.

const MAP_W := 40
const MAP_H := 30
const PROP_SCALE := 0.55

## Visual farmyard — forest belt outside; fence hugs this rect.
const FARM_ZONE := Rect2(96, 96, 1088, 768)
## Buildings/props must sit fully *inside* the fence (not just FARM_ZONE).
## Fence is drawn at FARM_ZONE Â±8; this rect insets past posts + roof clearance.
const FARM_BUILD_ZONE := Rect2(136, 136, 1008, 688)

const POND_CX := 30.5
const POND_CY := 23.0
const POND_RX := 4.0
const POND_RY := 2.8

## Dirt lane directly south of building footprints (tile Y).
## Must stay clear of building half_h around foot tile (~10 @ world y 336).
const DOOR_LANE_TY0 := 12
const DOOR_LANE_TY1 := 13

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H, "farm_home")
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
	_spawn_animals(ysort)
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
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _compute_pond_tile(tx: int, ty: int) -> bool:
	## Meandering farm pond — angular + multi-frequency noise so the shore is not a clean ellipse/rect.
	var nx: float = (float(tx) - POND_CX) / POND_RX
	var ny: float = (float(ty) - POND_CY) / POND_RY
	var ang: float = atan2(ny, nx)
	var meander: float = (
		0.32 * sin(ang * 3.0 + float(tx) * 0.38)
		+ 0.24 * cos(ang * 5.0 - float(ty) * 0.42)
		+ 0.16 * sin(float(tx) * 1.2 + float(ty) * 0.9)
		+ 0.12 * cos(float(tx) * 0.55 - float(ty) * 1.35)
		+ 0.08 * sin(float(tx + ty) * 0.7 + 1.1)
	)
	var d2: float = nx * nx + ny * ny
	var radius: float = 1.0 + meander
	if d2 <= radius * radius * 0.68:
		return true
	# Ragged fringe — not a filled elliptical ring.
	if d2 <= radius * radius and sin(float(tx) * 0.95 + float(ty) * 1.45 + ang * 2.2) > -0.22:
		return true
	# Occasional spit / inlet just outside the main body.
	if d2 <= (radius + 0.42) * (radius + 0.42) and sin(float(tx) * 1.75 + float(ty) * 0.62) > 0.52:
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
	# Door lane south of building footprints (no overlap with half_h around feet).
	_fill_dirt_rect(6, DOOR_LANE_TY0, 33, DOOR_LANE_TY1)
	# Door aprons only on the lane (not under building tiles).
	_fill_dirt_rect(18, DOOR_LANE_TY0, 21, DOOR_LANE_TY1) # farmhouse
	_fill_dirt_rect(7, DOOR_LANE_TY0, 10, DOOR_LANE_TY1) # coop
	_fill_dirt_rect(28, DOOR_LANE_TY0, 32, DOOR_LANE_TY1) # barn
	# Yard spine to gardens / pond.
	_fill_dirt_rect(18, DOOR_LANE_TY1, 21, 21)
	_fill_dirt_rect(6, 16, 33, 17)
	_fill_dirt_rect(11, 13, 12, 16)
	_fill_dirt_rect(17, 13, 18, 16)
	_fill_dirt_rect(25, 13, 26, 16)
	_fill_dirt_rect(22, 18, 28, 20)
	_fill_dirt_rect(28, 18, 31, 19, true)


func _paint_garden_beds() -> void:
	_fill_dirt_rect(6, 13, 10, 15)
	_fill_dirt_rect(13, 13, 16, 15)
	_fill_dirt_rect(22, 13, 24, 15)
	_fill_dirt_rect(27, 13, 31, 15)
	# Restore cross lanes.
	_fill_dirt_rect(11, 13, 12, 16)
	_fill_dirt_rect(17, 13, 18, 16)
	_fill_dirt_rect(18, 13, 21, 17)
	_fill_dirt_rect(25, 13, 26, 16)
	_fill_dirt_rect(6, 16, 33, 17)


func _paint_stone_approach() -> void:
	for ty in range(24, 29):
		for tx in range(18, 22):
			_set_path(tx, ty)
	for tx in range(18, 22):
		_set_dirt(tx, 21)
		_set_dirt(tx, 22)
		_set_dirt(tx, 23)


func _spawn_buildings(ysort: Node2D) -> void:
	# Foot Y â¥ ~352: margin past FARM_BUILD_ZONE top after tall-cottage AABB.
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(640, 352),
			"hw": 2, "hh": 1,
			"title": "农舍",
			"desc": "农舍完整落在院落围栏内：门朝南对土路。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(280, 352),
			"hw": 2, "hh": 1,
			"title": "鸡舍",
			"desc": "西北鸡舍，整栋在围栏内侧。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(980, 352),
			"hw": 2, "hh": 1,
			"title": "谷仓",
			"desc": "东北谷仓，整栋在围栏内侧。",
		},
	]
	for s in specs:
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var pos: Vector2 = s["pos"]
		# allow_path: door dirt/stone may touch footprint; water still blocked.
		var cleared := craft.find_building_inside(
			pos, tex, offset, FARM_BUILD_ZONE, int(s["hw"]), int(s["hh"]), 16, true
		)
		if cleared == Vector2.ZERO:
			push_warning("FarmResidential: could not place %s fully inside farm build zone" % s["title"])
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(36, 12))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.offset = offset
		if craft.has_method("mark_blocked_footprint"):
			craft.mark_blocked_footprint(pos, int(s["hw"]), int(s["hh"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		# Phase 5 Wave A: barn + coop door portals (door/foot anchor).
		if s["path"] == "res://assets/sprites/buildings/building_01.png":
			craft.make_portal(ysort, "进入谷仓", SceneRouter.C03_BARN_PATH, pos + Vector2(0, 26), Vector2(88, 48))
		elif s["path"] == "res://assets/sprites/buildings/building_04.png":
			craft.make_portal(ysort, "进入鸡舍", SceneRouter.C03_COOP_PATH, pos + Vector2(0, 26), Vector2(88, 48))


func _spawn_props(ysort: Node2D) -> void:
	# Yard defaults use upright barrel_1; small props match village residential scale 0.55.
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(420, 420), "title": "货箱", "desc": "菜畦旁货箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_1.png", "pos": Vector2(860, 420), "title": "木箱", "desc": "东畦旁木箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(540, 400), "title": "麻袋", "desc": "农舍前草皮麻袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(700, 440), "title": "粮袋", "desc": "院落粮袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(300, 420), "title": "木桶", "desc": "鸡舍旁木桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(1040, 420), "title": "水桶", "desc": "谷仓旁水桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(580, 480), "title": "院灯", "desc": "院落路灯。", "hw": 1, "hh": 1},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, false)
		if cleared == Vector2.ZERO:
			continue
		# Keep props inside the fenced build zone too.
		var tex := load(s["path"]) as Texture2D
		if tex and not craft.sprite_fully_inside(cleared, tex, Vector2.ZERO, FARM_BUILD_ZONE):
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.scale = Vector2(PROP_SCALE, PROP_SCALE)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_fences(ysort: Node2D) -> void:
	# Fence follows FARM_ZONE outer edge — buildings stay strictly inside.
	const POST := "res://assets/sprites/props/fence_post_00.png"
	var left := FARM_ZONE.position.x + 8.0
	var right := FARM_ZONE.end.x - 8.0
	var top := FARM_ZONE.position.y + 8.0
	var bottom := FARM_ZONE.end.y - 8.0
	var step := 40.0
	var segments: Array[Dictionary] = [
		{"origin": Vector2(left, top), "count": int((right - left) / step), "step": Vector2(step, 0), "title": "北围栏"},
		{"origin": Vector2(left, bottom), "count": int((right - left) / step), "step": Vector2(step, 0), "title": "南围栏"},
		{"origin": Vector2(left, top), "count": int((bottom - top) / step), "step": Vector2(0, step), "title": "西围栏"},
		{"origin": Vector2(right, top), "count": int((bottom - top) / step), "step": Vector2(0, step), "title": "东围栏"},
	]
	for seg in segments:
		var origin: Vector2 = seg["origin"]
		var st: Vector2 = seg["step"]
		var count: int = int(seg["count"])
		for i in range(count):
			var pos: Vector2 = origin + st * float(i)
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
			var hs := craft.make_hotspot(ysort, str(seg["title"]), "农场围栏：农舍等建筑均在围栏内侧。", pos, Vector2(24, 32))
			WorldSpawnUtil.attach_prop_sprite(hs.get_node("Visual") as Node2D, POST, 0.55)


func _spawn_trees(ysort: Node2D) -> void:
	# Forest belt outside fence — full crown AABB via spawn_tree + map play rect.
	# spawn_tree auto mark_blocked_footprint — do not duplicate.
	var map_zone := craft.map_play_rect(2.0)
	var forest := [
		Vector2(48, 48), Vector2(48, 480), Vector2(48, 900),
		Vector2(640, 48), Vector2(1200, 48), Vector2(1230, 480), Vector2(1230, 900),
		Vector2(400, 920), Vector2(800, 920),
	]
	for i in forest.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, forest[i], map_zone, 1, 1, 8, false)

	# Yard orchard inside fence on grass (not garden dirt) — AABB â FARM_BUILD_ZONE.
	var yard := [
		Vector2(160, 560), Vector2(1120, 560), Vector2(280, 700), Vector2(1000, 700),
	]
	for i in yard.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % ((i + 2) % 6)
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/trees/tree_%02d.png" % ((i + 2) % 6)
		craft.spawn_tree(ysort, path, yard[i], FARM_BUILD_ZONE, 1, 1, 8, false)


func _spawn_actors(ysort: Node2D) -> void:
	# PatrolActor walk cycles — never animate_patrol sliding (NPC_ANIM).
	var actors := [
		{
			"id": "farmer",
			"title": "农夫",
			"desc": "沿院落土路巡视菜圃。",
			"waypoints": [
				Vector2(640, 400),
				Vector2(640, 560),
				Vector2(400, 560),
				Vector2(400, 400),
				Vector2(640, 400),
			],
		},
		{
			"id": "elder_woman",
			"title": "帮手",
			"desc": "在农舍与谷仓前廊之间走动。",
			"waypoints": [
				Vector2(320, 380),
				Vector2(640, 380),
				Vector2(980, 380),
				Vector2(640, 380),
			],
		},
		{
			"id": "merchant",
			"title": "访客",
			"desc": "从南口走进院落（不下水塘）。",
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
		craft.spawn_patrol_actor(ysort, a["id"], a["title"], a["desc"], a["waypoints"])


func _spawn_animals(ysort: Node2D) -> void:
	# Auto height vs NPC (~56px) via AmbientCritter TARGET_HEIGHT_PX (pass scale <=0).
	var specs: Array[Dictionary] = [
		{"id": "cat", "pos": Vector2(300, 460)},
		{"id": "cat", "pos": Vector2(340, 500)},
		{"id": "cat", "pos": Vector2(260, 520)},
		{"id": "dog", "pos": Vector2(700, 520)},
		{"id": "sheep", "pos": Vector2(460, 620)},
		{"id": "cow", "pos": Vector2(980, 560)},
		{"id": "deer", "pos": Vector2(180, 640)},
	]
	for s in specs:
		_spawn_one_critter(ysort, str(s["id"]), s["pos"] as Vector2)


func _spawn_one_critter(ysort: Node2D, species: String, ideal: Vector2) -> void:
	var base := "res://assets/sprites/animals/%s/idle_0.png" % species
	if not ResourceLoader.exists(base):
		return
	var pos := craft.find_clear_near(ideal, 0, 0, 8, true)
	if pos == Vector2.ZERO:
		pos = ideal
	if craft.is_water(craft.world_to_tile(pos).x, craft.world_to_tile(pos).y):
		return
	var critter := AmbientCritter.new()
	ysort.add_child(critter)
	critter.setup(species, pos, craft, -1.0)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→住宅区", SceneRouter.RESIDENTIAL_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→农田", SceneRouter.FARMLAND_PATH, Vector2(640, 900), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
	# Wave D: farm warehouse east of barn + orchard annex near west yard trees.
	craft.make_portal(
		ysort, "进入仓库", SceneRouter.C37_WAREHOUSE_PATH, Vector2(1080, 380), Vector2(100, 52)
	)
	craft.make_portal(
		ysort, "进入果仓", SceneRouter.C52_ORCHARD_STORE_PATH, Vector2(200, 560), Vector2(100, 52)
	)
	# Wave E: farm production cellar west of farmhouse door lane.
	craft.make_portal(
		ysort, "进入地窖", SceneRouter.C50_FARM_CELLAR_PATH, Vector2(560, 400), Vector2(100, 52)
	)
