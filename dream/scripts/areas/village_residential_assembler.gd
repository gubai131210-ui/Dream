class_name VillageResidentialAssembler
extends Node

## A08 village residential — lane grid, yards, south-facing houses north of lanes.
## District: residential (AREA_FRAMEWORK). craft.setup(..., "residential").
## Uses AreaCraft for masks / paint / footprint / portals (do not duplicate helpers).
## Pass: masks -> ecology -> dirt -> water -> path -> buildings -> props -> trees -> actors -> FX.

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
		craft.mark_blocked_footprint(pos, int(s["hw"]), int(s["hh"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 20), Vector2(100, 72))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		# Phase 5 Wave A: door/foot portals — C01 player home + four distinct C02 villager templates.
		var home := _home_portal_for(str(s["path"]), s["pos"] as Vector2)
		if not home.is_empty():
			craft.make_portal(
				ysort,
				str(home["title"]),
				str(home["scene"]),
				pos + Vector2(0, 26),
				Vector2(88, 48)
			)


## Map cottage path+slot pos → interior portal (title + SceneRouter path).
## C01 stays on north-row west building_00; south-row houses get one C02 each.
func _home_portal_for(building_path: String, slot_pos: Vector2) -> Dictionary:
	# Player home (keep).
	if building_path == "res://assets/sprites/buildings/building_00.png" and slot_pos == Vector2(400, 280):
		return {"title": "进入住宅", "scene": SceneRouter.C01_HOME_PATH}
	# Merchant — west main-street cottage (square approach).
	if building_path == "res://assets/sprites/buildings/building_02.png" and slot_pos == Vector2(288, 520):
		return {"title": "进入商贾宅", "scene": SceneRouter.C02_MERCHANT_PATH}
	# Elder — mid main-street larger roof.
	if building_path == "res://assets/sprites/buildings/building_03.png" and slot_pos == Vector2(544, 520):
		return {"title": "进入老人宅", "scene": SceneRouter.C02_ELDER_PATH}
	# Farmer — east main-street toward farm portal.
	if building_path == "res://assets/sprites/buildings/building_04.png" and slot_pos == Vector2(800, 520):
		return {"title": "进入农家宅", "scene": SceneRouter.C02_FARMER_PATH}
	# Blacksmith home — east-corner cottage.
	if building_path == "res://assets/sprites/buildings/building_01.png" and slot_pos == Vector2(1000, 520):
		return {"title": "进入铁匠宅", "scene": SceneRouter.C02_BLACKSMITH_HOME_PATH}
	return {}


func _spawn_props(ysort: Node2D) -> void:
	# NE stone pocket well — enterable C14 well bottom (Wave A2 Well team).
	var well_path := "res://assets/sprites/props/well_0.png"
	if ResourceLoader.exists(well_path):
		var well_pos := Vector2(1184, 176)
		if not craft.is_water(craft.world_to_tile(well_pos).x, craft.world_to_tile(well_pos).y):
			craft.add_contact_shadow(ysort, well_pos, Vector2(20, 8))
			var wspr := craft.spawn_sprite(ysort, well_path, well_pos)
			wspr.scale = Vector2(0.55, 0.55)
			# Portal (scene_path) — not InfoPanel-only.
			craft.make_portal(
				ysort,
				"↓井底",
				SceneRouter.C14_WELL_PATH,
				well_pos + Vector2(0, 14),
				Vector2(72, 48)
			)

	var yard_props := [
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(250, 300), "title": "木桶", "desc": "西宅院落木桶。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(500, 300), "title": "木箱", "desc": "中宅院落货箱。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(760, 300), "title": "麻袋", "desc": "东宅院落麻袋。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(360, 200), "title": "长椅", "desc": "北巷旁歇脚长椅。", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(620, 480), "title": "路灯", "desc": "主巷路灯。", "hw": 1, "hh": 1, "allow_path": true},
		{"path": "res://assets/sprites/props/lamp_1.png", "pos": Vector2(880, 480), "title": "路灯", "desc": "主巷东段路灯。", "hw": 1, "hh": 1, "allow_path": true},
		{"path": "res://assets/sprites/props/well_1.png", "pos": Vector2(480, 280), "title": "院井", "desc": "宅院小井；可通下水道。", "hw": 1, "hh": 1, "sewer": true},
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
		if craft.is_water(craft.world_to_tile(pos).x, craft.world_to_tile(pos).y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.scale = Vector2(0.55, 0.55)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(44, 44))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		# Wave C C31 — yard well → sewer (distinct from NE C14 well).
		if bool(s.get("sewer", false)):
			craft.make_portal(
				ysort,
				"↓下水道",
				SceneRouter.C31_SEWER_PATH,
				pos + Vector2(0, 14),
				Vector2(72, 48)
			)

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
		Vector2(360, 160), Vector2(480, 160),
		Vector2(620, 160), Vector2(740, 160),
	]
	for i in posts.size():
		var pos := craft.find_clear_near(posts[i], 0, 0, 4, false)
		if pos == Vector2.ZERO:
			continue
		if craft.is_water(craft.world_to_tile(pos).x, craft.world_to_tile(pos).y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(8, 4))
		var spr := craft.spawn_sprite(ysort, fence_path, pos, -1)
		spr.scale = Vector2(0.55, 0.55)


func _spawn_trees(ysort: Node2D) -> void:
	# Border / yard trees — full crown AABB via spawn_tree (no north-edge clip).
	# Keep SE pond shoreline clear of crowns so rock_01 can sit on the bank.
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = [
		Vector2(120, 180),
		Vector2(200, 200),
		Vector2(100, 400),
		Vector2(140, 700),
		Vector2(400, 720),
		Vector2(700, 740),
		Vector2(920, 760),
		Vector2(1180, 220),
		Vector2(1200, 460),
		Vector2(500, 160),
		Vector2(780, 160),
		Vector2(1080, 160),
		Vector2(300, 520),
		Vector2(980, 280),
		Vector2(200, 560),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)
		if spr == null:
			continue
		var t := craft.world_to_tile(spr.position)
		if craft.is_bank(t.x, t.y) or craft.touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_se_pond_rock(ysort: Node2D) -> void:
	# SE pond bank: small rock cluster (not one cottage-tall boulder). Target ~22–28px tall.
	var tree_rects: Array[Rect2] = []
	for child in ysort.get_children():
		if child is Sprite2D:
			var ts: Sprite2D = child
			if ts.texture == null:
				continue
			var tp: String = str(ts.texture.resource_path)
			if not tp.contains("/trees/"):
				continue
			var toff := craft.tree_offset_for(ts.texture)
			tree_rects.append(craft.sprite_world_rect(ts.position, ts.texture, toff))

	var cluster := [
		{"path": "res://assets/sprites/props/rock_02.png", "pos": Vector2(1040, 620), "target_h": 24.0},
		{"path": "res://assets/sprites/props/rock_03.png", "pos": Vector2(1070, 640), "target_h": 20.0},
		{"path": "res://assets/sprites/props/rock_04.png", "pos": Vector2(1010, 640), "target_h": 18.0},
	]
	for s in cluster:
		if not ResourceLoader.exists(str(s["path"])):
			continue
		var tex := load(str(s["path"])) as Texture2D
		if tex == null:
			continue
		var scale_f: float = clampf(float(s["target_h"]) / float(tex.get_height()), 0.12, 0.35)
		var rock_size := Vector2(float(tex.get_width()), float(tex.get_height())) * scale_f
		var ideal: Vector2 = s["pos"]
		var pos := craft.find_clear_near(ideal, 0, 0, 8, false)
		if pos == Vector2.ZERO:
			pos = ideal
		if craft.is_water(craft.world_to_tile(pos).x, craft.world_to_tile(pos).y):
			continue
		var rock_rect := Rect2(pos - rock_size * 0.5, rock_size)
		var hits := false
		for tree_rect in tree_rects:
			if rock_rect.intersects(tree_rect):
				hits = true
				break
		if hits:
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(10, 4))
		var spr := craft.spawn_sprite(ysort, str(s["path"]), pos)
		spr.scale = Vector2(scale_f, scale_f)
		var hs := craft.make_hotspot(ysort, "岸石", "东南池塘岸边小石。", pos, Vector2(36, 36))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		tree_rects.append(rock_rect)


func _spawn_actors(ysort: Node2D) -> void:
	# PatrolActor walk frames — never tween-slide static sprites.
	var actors := [
		{
			"id": "elder_woman",
			"title": "邻居",
			"desc": "沿主巷土路散步。",
			"waypoints": [Vector2(320, 500), Vector2(560, 500), Vector2(800, 500), Vector2(560, 500)],
		},
		{
			"id": "farmer",
			"title": "孩童",
			"desc": "在主巷与南档口之间跑动。",
			"waypoints": [Vector2(640, 500), Vector2(640, 640), Vector2(640, 500)],
		},
		{
			"id": "merchant",
			"title": "访客",
			"desc": "从西石路走进住宅区。",
			"waypoints": [Vector2(80, 500), Vector2(240, 500), Vector2(400, 500), Vector2(240, 500)],
		},
	]
	for a in actors:
		craft.spawn_patrol_actor(ysort, a["id"], a["title"], a["desc"], a["waypoints"])


func _spawn_portals(ysort: Node2D) -> void:
	# West / north edges -> village square.
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
	# South / east -> farm home (SceneRouter.FARM_HOME_PATH).
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
	# Wave E: backyard annex north of west yard props.
	craft.make_portal(
		ysort,
		"进入后院",
		SceneRouter.C49_BACKYARD_PATH,
		Vector2(400, 260),
		Vector2(100, 52)
	)
