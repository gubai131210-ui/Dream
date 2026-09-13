class_name FarmlandAssembler
extends Node

## Farmland (A03) — irrigation stream, fenced crop beds, central shed hub.
## District: farmland (AREA_FRAMEWORK). craft.setup(..., "farmland").
## Layout follows A03_farmland.png: forest belt → fence → plots around dirt hub.
## Buildings: full sprite AABB inside FARM_BUILD_ZONE (BUILDING_PLACEMENT).

const MAP_W := 40
const MAP_H := 30
const PROP_SCALE := 0.55

## Visual farmyard — forest belt outside; fence hugs this rect.
const FARM_ZONE := Rect2(96, 96, 1088, 768)
## Buildings/props must sit fully *inside* the fence (not just FARM_ZONE).
const FARM_BUILD_ZONE := Rect2(136, 136, 1008, 688)

## Bridge bands where dirt path crosses the meandering stream (path_mask over water).
const BRIDGE_A_TY0 := 8
const BRIDGE_A_TY1 := 9
const BRIDGE_B_TY0 := 18
const BRIDGE_B_TY1 := 19

## Door dirt south of hub building footprints (tile Y).
const DOOR_LANE_TY0 := 14
const DOOR_LANE_TY1 := 15

var craft: AreaCraft = AreaCraft.new()

## Crop bed specs: tile rect + label + row color (world spawn after masks).
var _crop_beds: Array[Dictionary] = []


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H, "farmland")
	_rebuild_masks()
	craft.prepare_layers(ground, path, water)

	craft.paint_ecological_grass(ground)
	craft.paint_dirt_spurs(ground)
	craft.paint_water(water, ground)
	craft.paint_paths(path)

	_spawn_buildings(ysort)
	_spawn_crop_visuals(ysort)
	_spawn_bed_fences(ysort)
	_spawn_props(ysort)
	_spawn_perimeter_fence(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	_spawn_animals(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	_crop_beds.clear()

	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_stream_tile(x, y)

	_paint_hub_and_paths()
	_paint_crop_beds()
	_paint_bridges()

	# Paths / dirt / bridges win over water; banks after.
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _stream_center_x(ty: float) -> float:
	# West-of-hub irrigation meander (not Rect2i canal).
	return (
		10.2
		+ sin(ty * 0.38) * 2.55
		+ cos(ty * 0.16 + 0.8) * 1.55
		+ sin(ty * 0.11 + 0.4) * 0.95
		+ cos(ty * 0.73 + 1.2) * 0.65
	)


func _stream_half_width(ty: float) -> float:
	# Narrow irrigation: ~2â4 tiles most of the run, with irregular pinch/widen.
	return (
		1.35
		+ 0.7 * sin(ty * 0.27 + 0.6)
		+ 0.4 * cos(ty * 0.49)
		+ 0.25 * sin(ty * 0.91 + 0.3)
	)


func _compute_stream_tile(tx: int, ty: int) -> bool:
	# Keep stream inside farm playband (forest belt stays dry).
	if ty < 3 or ty > 26 or tx < 3 or tx > 19:
		return false
	var cx: float = _stream_center_x(float(ty))
	var hw: float = _stream_half_width(float(ty))
	var dx: float = absf(float(tx) - cx)
	if dx <= hw:
		return true
	# Soft ragged banks / oxbow nips — avoid straight canal walls.
	if dx <= hw + 1.15 and sin(float(ty) * 0.95 + float(tx) * 0.55 + cx * 0.2) > 0.35:
		return true
	if dx <= hw + 0.55 and cos(float(tx) * 1.3 - float(ty) * 0.7) > 0.62:
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


func _set_path(tx: int, ty: int, force: bool = false) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if craft.is_water(tx, ty) and not force:
		return
	if force:
		craft.water_mask[ty][tx] = false
	craft.path_mask[ty][tx] = true
	craft.dirt_mask[ty][tx] = false


func _fill_dirt(x0: int, y0: int, x1: int, y1: int, force: bool = false) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_dirt(tx, ty, force)


func _fill_path(x0: int, y0: int, x1: int, y1: int, force: bool = false) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_path(tx, ty, force)


func _paint_hub_and_paths() -> void:
	# Central dirt hub (packed earth around sheds).
	_fill_dirt(16, 11, 24, 17)
	# Door lane south of building feet (clear of half_h ~1 around ty~12â13).
	_fill_dirt(16, DOOR_LANE_TY0, 24, DOOR_LANE_TY1)
	_fill_dirt(17, DOOR_LANE_TY0, 19, DOOR_LANE_TY1) # west shed apron
	_fill_dirt(21, DOOR_LANE_TY0, 23, DOOR_LANE_TY1) # east barn apron

	# Hub ring roads (dirt, not stone plaza).
	_fill_dirt(15, 10, 25, 10)
	_fill_dirt(15, 17, 25, 17)
	_fill_dirt(15, 11, 15, 16)
	_fill_dirt(25, 11, 25, 16)

	# East spur to NE / SE beds.
	_fill_dirt(25, 12, 33, 13)
	_fill_dirt(29, 14, 30, 18)
	_fill_dirt(25, 18, 33, 19)

	# North spur to north beds.
	_fill_dirt(18, 5, 21, 10)

	# South spur to south beds / portal approach.
	_fill_dirt(18, 17, 21, 25)

	# West approaches to bridges (land anchors before stream).
	_fill_dirt(13, BRIDGE_A_TY0, 16, BRIDGE_A_TY1)
	_fill_dirt(13, BRIDGE_B_TY0, 16, BRIDGE_B_TY1)
	# Far-west bed connectors.
	_fill_dirt(4, BRIDGE_A_TY0, 8, BRIDGE_A_TY1)
	_fill_dirt(4, BRIDGE_B_TY0, 8, BRIDGE_B_TY1)
	_fill_dirt(5, 10, 6, 17)
	_fill_dirt(5, 5, 6, 8)
	_fill_dirt(5, 20, 6, 24)


func _paint_crop_beds() -> void:
	# â¥6 rectangular dirt beds around hub (avoid stream corridor ~tx 8â14).
	var beds: Array[Dictionary] = [
		{"x0": 4, "y0": 4, "x1": 8, "y1": 7, "title": "西北麦田", "desc": "灌溉渠西侧小麦畦。", "color": Color(0.78, 0.7, 0.28, 0.92), "rows": 4},
		{"x0": 4, "y0": 11, "x1": 8, "y1": 15, "title": "西蔬菜畦", "desc": "渠西绿叶蔬菜。", "color": Color(0.38, 0.68, 0.3, 0.9), "rows": 5},
		{"x0": 4, "y0": 20, "x1": 8, "y1": 24, "title": "西南菜畦", "desc": "南端叶菜畦。", "color": Color(0.42, 0.74, 0.32, 0.9), "rows": 4},
		{"x0": 16, "y0": 4, "x1": 22, "y1": 7, "title": "北麦田", "desc": "中心枢纽北侧麦田。", "color": Color(0.82, 0.74, 0.3, 0.92), "rows": 3},
		{"x0": 27, "y0": 4, "x1": 33, "y1": 8, "title": "东北麦田", "desc": "东侧金黄麦田。", "color": Color(0.8, 0.72, 0.26, 0.92), "rows": 4},
		{"x0": 28, "y0": 11, "x1": 33, "y1": 15, "title": "东蔬菜畦", "desc": "谷仓东侧菜畦。", "color": Color(0.35, 0.66, 0.28, 0.9), "rows": 5},
		{"x0": 27, "y0": 20, "x1": 33, "y1": 24, "title": "东南菜畦", "desc": "东南角蔬菜畦。", "color": Color(0.48, 0.7, 0.34, 0.9), "rows": 4},
		{"x0": 16, "y0": 20, "x1": 23, "y1": 24, "title": "南麦田", "desc": "枢纽南侧麦田。", "color": Color(0.76, 0.68, 0.25, 0.92), "rows": 4},
	]
	for b in beds:
		craft.mark_dirt_rect(int(b["x0"]), int(b["y0"]), int(b["x1"]), int(b["y1"]))
		_crop_beds.append(b)
	# Restore hub ring after bed paint (beds must not erase main lanes).
	_fill_dirt(16, 11, 24, 17)
	_fill_dirt(18, 5, 21, 10)
	_fill_dirt(18, 17, 21, 25)
	_fill_dirt(25, 12, 33, 13)
	_fill_dirt(25, 18, 33, 19)


func _paint_bridges() -> void:
	# Bridge decks: path_mask over water (paint_water skips path cells).
	_paint_bridge_band(BRIDGE_A_TY0, BRIDGE_A_TY1)
	_paint_bridge_band(BRIDGE_B_TY0, BRIDGE_B_TY1)


func _paint_bridge_band(ty0: int, ty1: int) -> void:
	var lo := MAP_W
	var hi := -1
	for ty in [ty0, ty1]:
		for tx in range(MAP_W):
			if craft.is_water(tx, ty):
				lo = mini(lo, tx)
				hi = maxi(hi, tx)
	if hi < 0:
		# Fallback mid-stream crossing.
		lo = 9
		hi = 12
	# Widen to 3â5 for a readable span, then deck + one land anchor each side.
	var width := hi - lo + 1
	if width < 3:
		hi = mini(MAP_W - 1, lo + 2)
	elif width > 5:
		var mid: int = floori(float(lo + hi) / 2.0)
		lo = mid - 2
		hi = mid + 2
	for ty in [ty0, ty1]:
		for tx in range(lo - 1, hi + 2):
			_set_path(tx, ty, true)


func _spawn_buildings(ysort: Node2D) -> void:
	# Foot Y ≥ ~352: tall sheets clear FARM_BUILD_ZONE top (same lock as A02).
	# Wave C: east shed = 磨坊 (enterable C13).
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(560, 400),
			"hw": 2, "hh": 1,
			"title": "农具棚",
			"desc": "农田中心工具棚：门朝南对土路枢纽（加工棚入口）。",
			"enter_title": "进入加工棚",
			"enter_scene": SceneRouter.C39_PROCESSING_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(720, 400),
			"hw": 2, "hh": 1,
			"title": "磨坊",
			"desc": "枢纽东侧磨坊风车，整栋在围栏内侧。",
			"enter_title": "进入磨坊",
			"enter_scene": SceneRouter.C13_MILL_PATH,
		},
	]
	for s in specs:
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_building_inside(
			pos, tex, offset, FARM_BUILD_ZONE, int(s["hw"]), int(s["hh"]), 16, true
		)
		if cleared == Vector2.ZERO:
			push_warning("Farmland: could not place %s fully inside farm build zone" % s["title"])
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
		if s.has("enter_scene"):
			craft.make_portal(
				ysort,
				str(s["enter_title"]),
				str(s["enter_scene"]),
				pos + Vector2(0, 28),
				Vector2(100, 52)
			)


func _spawn_crop_visuals(ysort: Node2D) -> void:
	for b in _crop_beds:
		var x0: int = int(b["x0"])
		var y0: int = int(b["y0"])
		var x1: int = int(b["x1"])
		var y1: int = int(b["y1"])
		var bed := Rect2(
			float(x0) * float(craft.tile),
			float(y0) * float(craft.tile),
			float(x1 - x0 + 1) * float(craft.tile),
			float(y1 - y0 + 1) * float(craft.tile)
		)
		craft.spawn_crop_rows(
			ysort, bed, str(b["title"]), str(b["desc"]), b["color"] as Color, int(b["rows"])
		)


func _spawn_bed_fences(ysort: Node2D) -> void:
	# Low post fence around each crop bed (visual only) — sprite posts (G8).
	const POST := "res://assets/sprites/props/fence_post_00.png"
	for b in _crop_beds:
		var x0: int = int(b["x0"])
		var y0: int = int(b["y0"])
		var x1: int = int(b["x1"])
		var y1: int = int(b["y1"])
		var left := float(x0) * float(craft.tile) + 4.0
		var right := float(x1 + 1) * float(craft.tile) - 4.0
		var top := float(y0) * float(craft.tile) + 4.0
		var bottom := float(y1 + 1) * float(craft.tile) - 4.0
		var step := 28.0
		var posts: Array[Vector2] = []
		var x := left
		while x <= right + 0.5:
			posts.append(Vector2(x, top))
			posts.append(Vector2(x, bottom))
			x += step
		var y := top + step
		while y < bottom - 0.5:
			posts.append(Vector2(left, y))
			posts.append(Vector2(right, y))
			y += step
		for pos in posts:
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
			var hs := craft.make_hotspot(
				ysort, "田埂桩", "%s围桩" % str(b["title"]), pos, Vector2(18, 22)
			)
			WorldSpawnUtil.attach_prop_sprite(hs.get_node("Visual") as Node2D, POST, 0.45)


func _spawn_props(ysort: Node2D) -> void:
	# Upright barrel_1 default; small props scaled to match village residential (0.55).
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(500, 480), "title": "货箱", "desc": "枢纽旁货箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(640, 500), "title": "麻袋", "desc": "粮袋堆在土路旁。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(780, 490), "title": "粮袋", "desc": "仓储棚前粮袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(520, 520), "title": "木桶", "desc": "灌溉旁木桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(640, 560), "title": "田灯", "desc": "农田枢纽路灯。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_1.png", "pos": Vector2(900, 460), "title": "木箱", "desc": "东畦旁木箱。", "hw": 1, "hh": 1},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, true)
		if cleared == Vector2.ZERO:
			continue
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


func _spawn_perimeter_fence(ysort: Node2D) -> void:
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
			var hs := craft.make_hotspot(
				ysort, str(seg["title"]), "农田外圈围栏：建筑与菜田均在围栏内侧。", pos, Vector2(24, 32)
			)
			WorldSpawnUtil.attach_prop_sprite(hs.get_node("Visual") as Node2D, POST, 0.55)


func _spawn_trees(ysort: Node2D) -> void:
	# Forest belt OUTSIDE farm zone — full crown AABB via spawn_tree.
	# spawn_tree auto mark_blocked_footprint — do not duplicate.
	var map_zone := craft.map_play_rect(2.0)
	var forest := [
		Vector2(48, 48), Vector2(48, 320), Vector2(48, 640), Vector2(48, 900),
		Vector2(320, 48), Vector2(640, 40), Vector2(960, 48), Vector2(1200, 48),
		Vector2(1230, 320), Vector2(1230, 640), Vector2(1230, 900),
		Vector2(320, 920), Vector2(640, 930), Vector2(960, 920),
	]
	for i in forest.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, forest[i], map_zone, 1, 1, 8, false)

	# Sparse yard shade trees inside fence on grass gaps (not crop dirt) — AABB â FARM_BUILD_ZONE.
	var yard := [
		Vector2(400, 300), Vector2(1000, 280), Vector2(360, 640), Vector2(1000, 640),
	]
	for i in yard.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % ((i + 3) % 6)
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/trees/tree_%02d.png" % ((i + 3) % 6)
		craft.spawn_tree(ysort, path, yard[i], FARM_BUILD_ZONE, 1, 1, 8, false)


func _spawn_actors(ysort: Node2D) -> void:
	# PatrolActor walk cycles — never animate_patrol sliding (NPC_ANIM).
	var actors := [
		{
			"id": "farmer",
			"title": "田农",
			"desc": "沿枢纽土路巡视菜圃。",
			"waypoints": [
				Vector2(640, 480),
				Vector2(800, 420),
				Vector2(640, 560),
				Vector2(480, 420),
				Vector2(640, 480),
			],
		},
		{
			"id": "miller",
			"title": "灌溉工",
			"desc": "在桥与西圃之间快步巡渠。",
			"waypoints": [
				Vector2(200, 280),
				Vector2(400, 280),
				Vector2(400, 600),
				Vector2(200, 600),
				Vector2(200, 280),
			],
		},
		{
			"id": "elder_woman",
			"title": "歇脚老妇",
			"desc": "在南篱土路边慢慢走动歇息。",
			"waypoints": [
				Vector2(480, 700),
				Vector2(640, 720),
				Vector2(800, 700),
				Vector2(640, 680),
				Vector2(480, 700),
			],
		},
		{
			"id": "blacksmith",
			"title": "仓前帮手",
			"desc": "在工具棚与仓储棚前廊之间走动。",
			"waypoints": [
				Vector2(560, 460),
				Vector2(720, 460),
				Vector2(720, 540),
				Vector2(560, 540),
				Vector2(560, 460),
			],
		},
	]
	for a in actors:
		craft.spawn_patrol_actor(ysort, a["id"], a["title"], a["desc"], a["waypoints"])


func _spawn_animals(ysort: Node2D) -> void:
	# Auto height vs NPC via AmbientCritter (scale <=0). Dense cats; sparse livestock.
	var specs: Array[Dictionary] = [
		{"id": "cat", "pos": Vector2(220, 420)},
		{"id": "cat", "pos": Vector2(240, 680)},
		{"id": "cat", "pos": Vector2(980, 420)},
		{"id": "cat", "pos": Vector2(1000, 680)},
		{"id": "dog", "pos": Vector2(640, 620)},
		{"id": "sheep", "pos": Vector2(420, 300)},
		{"id": "cow", "pos": Vector2(880, 300)},
		{"id": "deer", "pos": Vector2(200, 520)},
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
	craft.make_portal(ysort, "→农场住宅", SceneRouter.FARM_HOME_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
	# Wave D: apiary meadow entry (north edge — ≠ mill C13 / processing shed).
	craft.make_portal(
		ysort, "进入蜂场", SceneRouter.C51_APIARY_PATH, Vector2(280, 200), Vector2(100, 52)
	)
