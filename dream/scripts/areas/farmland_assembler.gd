class_name FarmlandAssembler
extends Node

## Farmland (A03) — irrigation stream, fenced crop beds, central shed hub.
## District: farmland (AREA_FRAMEWORK). craft.setup(..., "farmland").
## Layout follows A03_farmland.png: forest belt → fence → plots around dirt hub.
## Buildings: full sprite AABB inside FARM_BUILD_ZONE (BUILDING_PLACEMENT).

const MAP_W := 40
const MAP_H := 30

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
	return 10.2 + sin(ty * 0.38) * 2.2 + cos(ty * 0.16 + 0.8) * 1.35 + sin(ty * 0.11 + 0.4) * 0.75


func _stream_half_width(ty: float) -> float:
	# Narrow irrigation: ~2–4 tiles most of the run.
	return 1.45 + 0.55 * sin(ty * 0.27 + 0.6) + 0.3 * cos(ty * 0.49)


func _compute_stream_tile(tx: int, ty: int) -> bool:
	# Keep stream inside farm playband (forest belt stays dry).
	if ty < 3 or ty > 26 or tx < 4 or tx > 18:
		return false
	var cx: float = _stream_center_x(float(ty))
	var hw: float = _stream_half_width(float(ty))
	var dx: float = absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 0.95 and sin(float(ty) * 0.9 + float(tx) * 0.45) > 0.48:
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
	# Door lane south of building feet (clear of half_h ~1 around ty~12–13).
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
	# ≥6 rectangular dirt beds around hub (avoid stream corridor ~tx 8–14).
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
	# Widen to 3–5 for a readable span, then deck + one land anchor each side.
	var width := hi - lo + 1
	if width < 3:
		hi = mini(MAP_W - 1, lo + 2)
	elif width > 5:
		var mid: int = int((lo + hi) / 2)
		lo = mid - 2
		hi = mid + 2
	for ty in [ty0, ty1]:
		for tx in range(lo - 1, hi + 2):
			_set_path(tx, ty, true)


func _spawn_buildings(ysort: Node2D) -> void:
	# Foot Y ≥ ~352: tall sheets clear FARM_BUILD_ZONE top (same lock as A02).
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(560, 400),
			"hw": 2, "hh": 1,
			"title": "农具棚",
			"desc": "农田中心工具棚：门朝南对土路枢纽。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(720, 400),
			"hw": 2, "hh": 1,
			"title": "仓储棚",
			"desc": "枢纽东侧仓储棚（风车占位），整栋在围栏内侧。",
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
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


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
	# Low post fence around each crop bed (visual only).
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
			var post := ColorRect.new()
			post.size = Vector2(6, 14)
			post.position = Vector2(-3, -12)
			post.color = Color(0.4, 0.26, 0.12, 0.8)
			var hs := craft.make_hotspot(
				ysort, "畦栏", "%s围栏" % str(b["title"]), pos, Vector2(18, 22)
			)
			hs.get_node("Visual").add_child(post)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(500, 480), "title": "货箱", "desc": "枢纽旁货箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(640, 500), "title": "麻袋", "desc": "粮袋堆在土路旁。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(780, 490), "title": "粮袋", "desc": "仓储棚前粮袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(520, 520), "title": "木桶", "desc": "灌溉旁木桶。", "hw": 1, "hh": 1},
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
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_perimeter_fence(ysort: Node2D) -> void:
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
			var post := ColorRect.new()
			post.size = Vector2(8, 22)
			post.position = Vector2(-4, -18)
			post.color = Color(0.42, 0.28, 0.14, 0.85)
			var hs := craft.make_hotspot(
				ysort, str(seg["title"]), "农田外圈围栏：建筑与菜畦均在围栏内侧。", pos, Vector2(24, 32)
			)
			hs.get_node("Visual").add_child(post)


func _spawn_trees(ysort: Node2D) -> void:
	# Forest belt OUTSIDE farm zone.
	var ideals := [
		Vector2(48, 48), Vector2(48, 320), Vector2(48, 640), Vector2(48, 900),
		Vector2(320, 48), Vector2(640, 40), Vector2(960, 48), Vector2(1200, 48),
		Vector2(1230, 320), Vector2(1230, 640), Vector2(1230, 900),
		Vector2(320, 920), Vector2(640, 930), Vector2(960, 920),
		Vector2(200, 160), Vector2(1080, 160),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 8, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y) or craft.is_bank(t.x, t.y) or craft.is_dirt(t.x, t.y):
			continue
		# Prefer outside / on edge of farm zone (forest belt).
		if FARM_BUILD_ZONE.has_point(pos):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(22, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)


func _spawn_actors(ysort: Node2D) -> void:
	var actors := [
		{
			"path": "res://assets/sprites/npc/npc_00.png",
			"title": "田农",
			"desc": "沿枢纽土路巡视菜畦。",
			"waypoints": [
				Vector2(640, 480),
				Vector2(800, 420),
				Vector2(640, 560),
				Vector2(480, 420),
				Vector2(640, 480),
			],
		},
		{
			"path": "res://assets/sprites/npc/npc_01.png",
			"title": "灌溉工",
			"desc": "在桥与西畦之间走动。",
			"waypoints": [
				Vector2(200, 280),
				Vector2(400, 280),
				Vector2(400, 600),
				Vector2(200, 600),
				Vector2(200, 280),
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
	craft.make_portal(ysort, "→农场住宅", SceneRouter.FARM_HOME_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
