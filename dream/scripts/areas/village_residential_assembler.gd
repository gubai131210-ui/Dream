class_name VillageResidentialAssembler
extends Node

## A08 village residential — lane grid, yards, south-facing houses north of lanes.
## District: residential (AREA_FRAMEWORK). craft.setup(..., "residential").
## Uses AreaCraft for masks / paint / footprint / portals (do not duplicate helpers).
## Pass: masks → ecology → dirt → water → path → buildings → props → trees → actors → FX.

const MAP_W := 40
const MAP_H := 30

## Main east-west dirt lane (houses sit NORTH; doors face this lane).
const MAIN_LANE_TY0 := 18
const MAIN_LANE_TY1 := 19
## Secondary north EW lane for the upper house row.
const NORTH_LANE_TY0 := 10
const NORTH_LANE_TY1 := 11

## Full sprite AABB must stay inside this play rect (forest/edge margin).
const PLAY_ZONE := Rect2(64, 64, 1152, 832)

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H, "residential")
	_rebuild_masks()
	craft.prepare_layers(ground, path, water)

	craft.paint_ecological_grass(ground)
	craft.paint_dirt_spurs(ground)
	craft.paint_water(water, ground)
	craft.paint_paths(path)

	_spawn_buildings(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	_spawn_portals(ysort)
	craft.spawn_water_overlay(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_pond_tile(x, y)
			craft.path_mask[y][x] = false
			craft.dirt_mask[y][x] = false
			craft.bank_mask[y][x] = false

	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_water(x, y):
				continue
			craft.dirt_mask[y][x] = _compute_dirt_lane(x, y)
			craft.path_mask[y][x] = _compute_stone_path(x, y)

	_paint_door_spur_masks()
	# Stone wins over dirt where both set (west approach / plaza pocket).
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.path_mask[y][x]:
				craft.dirt_mask[y][x] = false

	craft.rebuild_banks()


func _pond_center() -> Vector2:
	# SE residential pond — oval / meander, not a Rect2i canal.
	return Vector2(33.2, 23.4)


func _compute_pond_tile(tx: int, ty: int) -> bool:
	var c := _pond_center()
	var dx: float = (float(tx) - c.x) / 3.4
	var dy: float = (float(ty) - c.y) / 2.6
	var wobble: float = 0.18 * sin(float(tx) * 0.9 + float(ty) * 0.55) + 0.12 * cos(float(ty) * 0.7)
	var r2: float = dx * dx + dy * dy
	if r2 <= 1.0 + wobble:
		return true
	if r2 <= 1.35 + wobble and sin(float(tx) * 1.1 + float(ty) * 0.8) > 0.45:
		return true
	return false


func _compute_dirt_lane(tx: int, ty: int) -> bool:
	# Main EW residential street.
	if ty >= MAIN_LANE_TY0 and ty <= MAIN_LANE_TY1 and tx >= 4 and tx <= 37:
		return true
	# North EW lane (upper row doors).
	if ty >= NORTH_LANE_TY0 and ty <= NORTH_LANE_TY1 and tx >= 4 and tx <= 37:
		return true
	# NS alleys separating house lots (grid like A08).
	var alley_xs: Array[int] = [7, 8, 15, 16, 23, 24, 31, 32]
	if ty >= NORTH_LANE_TY0 and ty <= MAIN_LANE_TY1 and tx in alley_xs:
		return true
	# South spur toward farm portal.
	if tx >= 19 and tx <= 20 and ty >= MAIN_LANE_TY1 and ty <= 28:
		return true
	# East spur toward farm edge.
	if ty >= MAIN_LANE_TY0 and ty <= MAIN_LANE_TY1 and tx >= 32 and tx <= 38:
		return true
	# Short north spur from north lane toward square portal.
	if tx >= 19 and tx <= 20 and ty >= 1 and ty < NORTH_LANE_TY0:
		return true
	return false


func _compute_stone_path(tx: int, ty: int) -> bool:
	# West approach to square — stone on main lane head.
	if ty >= MAIN_LANE_TY0 and ty <= MAIN_LANE_TY1 and tx >= 0 and tx <= 5:
		return true
	# Small NE pocket plaza — keep clear of house lots.
	if tx >= 36 and tx <= 38 and ty >= 4 and ty <= 6:
		return true
	# North-west connector strip toward square portal.
	if tx >= 0 and tx <= 2 and ty >= 4 and ty <= MAIN_LANE_TY1:
		return true
	return false


func _paint_door_spur_masks() -> void:
	# Dirt aprons from lanes up to south-facing doors (house slots below).
	var spurs: Array[Vector2i] = [
		# Main-lane row aprons (just north of MAIN_LANE).
		Vector2i(8, 17), Vector2i(9, 17),
		Vector2i(16, 17), Vector2i(17, 17),
		Vector2i(24, 17), Vector2i(25, 17),
		Vector2i(29, 17), Vector2i(30, 17),
		# North-lane row aprons.
		Vector2i(11, 9), Vector2i(12, 9),
		Vector2i(19, 9), Vector2i(20, 9),
		Vector2i(27, 9), Vector2i(28, 9),
	]
	for c in spurs:
		if c.x < 0 or c.y < 0 or c.x >= MAP_W or c.y >= MAP_H:
			continue
		if craft.is_water(c.x, c.y):
			continue
		if craft.path_mask[c.y][c.x]:
			continue
		craft.dirt_mask[c.y][c.x] = true


func _house_slots() -> Array:
	# South-facing cottages NORTH of their door lane — foot Y leaves full sprite inside PLAY_ZONE.
	return [
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(288, 520),
			"hw": 2, "hh": 1,
			"title": "西巷民居",
			"desc": "主巷北侧住宅：整栋在住宅区内，门朝南。",
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(544, 520),
			"hw": 2, "hh": 1,
			"title": "中巷民居",
			"desc": "主巷中段北侧宅院。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(800, 520),
			"hw": 2, "hh": 1,
			"title": "东巷民居",
			"desc": "主巷东段北侧小屋。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(1000, 520),
			"hw": 2, "hh": 1,
			"title": "东角宅",
			"desc": "东段住宅，整栋在区内。",
		},
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(400, 280),
			"hw": 2, "hh": 1,
			"title": "北排西宅",
			"desc": "北巷北侧住宅：屋顶不穿出地图上沿。",
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(656, 280),
			"hw": 2, "hh": 1,
			"title": "北排中宅",
			"desc": "北巷中段宅院。",
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(912, 280),
			"hw": 2, "hh": 1,
			"title": "北排东宅",
			"desc": "北巷东端住宅。",
		},
	]


func _spawn_buildings(ysort: Node2D) -> void:
	for s in _house_slots():
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_building_inside(
			pos, tex, offset, PLAY_ZONE, int(s["hw"]), int(s["hh"]), 16, false
		)
		if cleared == Vector2.ZERO:
			push_warning("VillageResidential: could not place %s fully inside play zone" % s["title"])
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(32, 11))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.offset = offset
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 20), Vector2(100, 72))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	# NE stone pocket well / fountain (civic on path ok).
	var well_path := "res://assets/sprites/props/well_0.png"
	if ResourceLoader.exists(well_path):
		var well_pos := Vector2(1184, 176)
		if not craft.is_water(craft.world_to_tile(well_pos).x, craft.world_to_tile(well_pos).y):
			craft.add_contact_shadow(ysort, well_pos, Vector2(20, 8))
			var wspr := craft.spawn_sprite(ysort, well_path, well_pos)
			var whs := craft.make_hotspot(ysort, "石井", "住宅区东北石坪水井。", well_pos, Vector2(64, 48))
			wspr.reparent(whs.get_node("Visual"))
			wspr.position = Vector2.ZERO

	var yard_props := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(250, 300), "title": "木桶", "desc": "西宅院落木桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(500, 300), "title": "木箱", "desc": "中宅院落货箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(760, 300), "title": "麻袋", "desc": "东宅院落麻袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(360, 200), "title": "长椅", "desc": "北巷旁歇脚长椅。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(620, 480), "title": "路灯", "desc": "主巷路灯。", "hw": 1, "hh": 1, "allow_path": true},
		{"path": "res://assets/sprites/props/lamp_1.png", "pos": Vector2(880, 480), "title": "路灯", "desc": "主巷东段路灯。", "hw": 1, "hh": 1, "allow_path": true},
		{"path": "res://assets/sprites/props/well_1.png", "pos": Vector2(480, 280), "title": "院井", "desc": "宅院小井。", "hw": 1, "hh": 1},
	]
	for s in yard_props:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var allow: bool = bool(s.get("allow_path", false))
		if allow:
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
		else:
			var cleared := craft.find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, false)
			if cleared == Vector2.ZERO:
				continue
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(44, 44))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO

	_spawn_fence_props(ysort)


func _spawn_fence_props(ysort: Node2D) -> void:
	# Optional yard fence markers (props only — not a full collision fence system).
	var fence_path := "res://assets/sprites/props/B11-08_pots_lamps_00.png"
	if not ResourceLoader.exists(fence_path):
		fence_path = "res://assets/sprites/props/lamp_2.png"
	if not ResourceLoader.exists(fence_path):
		return
	var posts: Array[Vector2] = [
		Vector2(220, 320), Vector2(340, 320),
		Vector2(480, 320), Vector2(600, 320),
		Vector2(740, 320), Vector2(860, 320),
		Vector2(360, 90), Vector2(480, 90),
		Vector2(620, 90), Vector2(740, 90),
	]
	for i in posts.size():
		var pos := craft.find_clear_near(posts[i], 0, 0, 4, false)
		if pos == Vector2.ZERO:
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(8, 4))
		var spr := craft.spawn_sprite(ysort, fence_path, pos, -1)
		spr.scale = Vector2(0.55, 0.55)


func _spawn_trees(ysort: Node2D) -> void:
	# Border / yard trees — plantable only via footprint_ok.
	var ideals: Array[Vector2] = [
		Vector2(120, 80),
		Vector2(200, 200),
		Vector2(100, 400),
		Vector2(140, 700),
		Vector2(400, 720),
		Vector2(700, 740),
		Vector2(1000, 700),
		Vector2(1180, 200),
		Vector2(1180, 520),
		Vector2(500, 80),
		Vector2(780, 80),
		Vector2(1080, 80),
		Vector2(300, 520),
		Vector2(980, 280),
		Vector2(200, 560),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 8, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if not craft.is_plantable(t.x, t.y):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(20, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)
		if craft.is_bank(t.x, t.y) or craft.touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_actors(ysort: Node2D) -> void:
	var actors := [
		{
			"path": "res://assets/sprites/npc/npc_00.png",
			"title": "邻居",
			"desc": "沿主巷土路散步。",
			"waypoints": [Vector2(320, 500), Vector2(560, 500), Vector2(800, 500), Vector2(560, 500)],
		},
		{
			"path": "res://assets/sprites/npc/npc_01.png",
			"title": "孩童",
			"desc": "在主巷与南岔口之间跑动。",
			"waypoints": [Vector2(640, 500), Vector2(640, 640), Vector2(640, 500)],
		},
		{
			"path": "res://assets/sprites/npc/npc_02.png",
			"title": "访客",
			"desc": "从西石路走进住宅区。",
			"waypoints": [Vector2(80, 500), Vector2(240, 500), Vector2(400, 500), Vector2(240, 500)],
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
		craft.add_contact_shadow(visual, Vector2.ZERO, Vector2(12, 5))
		var spr := craft.spawn_sprite(visual, a["path"], Vector2.ZERO)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		craft.animate_patrol(hs, route)


func _spawn_portals(ysort: Node2D) -> void:
	# West / north edges → village square.
	craft.make_portal(
		ysort,
		"→广场",
		SceneRouter.SQUARE_PATH,
		Vector2(40, 500),
		Vector2(72, 56)
	)
	craft.make_portal(
		ysort,
		"→广场",
		SceneRouter.SQUARE_PATH,
		Vector2(640, 40),
		Vector2(96, 48)
	)
	# South / east → farm home (SceneRouter.FARM_HOME_PATH).
	craft.make_portal(
		ysort,
		"→农场",
		SceneRouter.FARM_HOME_PATH,
		Vector2(640, 900),
		Vector2(96, 48)
	)
	craft.make_portal(
		ysort,
		"→农场",
		SceneRouter.FARM_HOME_PATH,
		Vector2(1220, 500),
		Vector2(72, 56)
	)
