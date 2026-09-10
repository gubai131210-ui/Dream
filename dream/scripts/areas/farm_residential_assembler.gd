class_name FarmResidentialAssembler
extends Node

## Farm residential (A02) â AreaCraft masks + layered assemble.
## District: farm_home (AREA_FRAMEWORK). craft.setup(..., "farm_home").
## Buildings must sit FULLY inside the farm play zone (sprite AABB), not straddling fence/forest.

const MAP_W := 40
const MAP_H := 30

## Visual farmyard â forest belt outside; fence hugs this rect.
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
	var nx: float = (float(tx) - POND_CX) / POND_RX
	var ny: float = (float(ty) - POND_CY) / POND_RY
	var d2: float = nx * nx + ny * ny
	if d2 <= 1.0:
		return true
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
			"title": "åè",
			"desc": "åèå®æ´è½å¨é¢è½å´æ åï¼é¨æåå¯¹åè·¯ã",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(280, 352),
			"hw": 2, "hh": 1,
			"title": "é¸¡è",
			"desc": "è¥¿åé¸¡èï¼æ´æ å¨å´æ åä¾§ã",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(980, 352),
			"hw": 2, "hh": 1,
			"title": "è°·ä»",
			"desc": "ä¸åè°·ä»ï¼æ´æ å¨å´æ åä¾§ã",
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
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(420, 420), "title": "è´§ç®±", "desc": "èç¦æè´§ç®±ã", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_1.png", "pos": Vector2(860, 420), "title": "æ¨ç®±", "desc": "ä¸ç¦ææ¨ç®±ã", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(540, 400), "title": "éº»è¢", "desc": "åèåèç®éº»è¢ã", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(700, 440), "title": "ç²®è¢", "desc": "é¢è½ç²®è¢ã", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(300, 420), "title": "æ¨æ¡¶", "desc": "é¸¡èææ¨æ¡¶ã", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(1040, 420), "title": "æ°´æ¡¶", "desc": "è°·ä»ææ°´æ¡¶ã", "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(580, 480), "title": "é¢ç¯", "desc": "é¢è½è·¯ç¯ã", "hw": 1, "hh": 1},
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
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_fences(ysort: Node2D) -> void:
	# Fence follows FARM_ZONE outer edge â buildings stay strictly inside, never straddling.
	var left := FARM_ZONE.position.x + 8.0
	var right := FARM_ZONE.end.x - 8.0
	var top := FARM_ZONE.position.y + 8.0
	var bottom := FARM_ZONE.end.y - 8.0
	var step := 40.0
	var segments: Array[Dictionary] = [
		{"origin": Vector2(left, top), "count": int((right - left) / step), "step": Vector2(step, 0), "title": "åå´æ "},
		{"origin": Vector2(left, bottom), "count": int((right - left) / step), "step": Vector2(step, 0), "title": "åå´æ "},
		{"origin": Vector2(left, top), "count": int((bottom - top) / step), "step": Vector2(0, step), "title": "è¥¿å´æ "},
		{"origin": Vector2(right, top), "count": int((bottom - top) / step), "step": Vector2(0, step), "title": "ä¸å´æ "},
	]
	for seg in segments:
		var origin: Vector2 = seg["origin"]
		var st: Vector2 = seg["step"]
		var count: int = int(seg["count"])
		for i in range(count):
			var pos: Vector2 = origin + st * float(i)
			# Skip fence posts that would sit on portals / pond water tiles.
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
			var post := ColorRect.new()
			post.size = Vector2(8, 22)
			post.position = Vector2(-4, -18)
			post.color = Color(0.42, 0.28, 0.14, 0.85)
			var hs := craft.make_hotspot(ysort, str(seg["title"]), "ååºå´æ ï¼åèç­å»ºç­åå¨å´æ åä¾§ã", pos, Vector2(24, 32))
			hs.get_node("Visual").add_child(post)


func _spawn_trees(ysort: Node2D) -> void:
	# Forest belt outside fence — full crown AABB via spawn_tree + map play rect.
	var map_zone := craft.map_play_rect(2.0)
	var forest := [
		Vector2(48, 48), Vector2(48, 480), Vector2(48, 900),
		Vector2(640, 48), Vector2(1200, 48), Vector2(1230, 480), Vector2(1230, 900),
		Vector2(400, 920), Vector2(800, 920),
	]
	for i in forest.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, forest[i], map_zone, 1, 1, 8, false)

	# Yard orchard inside fence on grass (not garden dirt) — AABB ⊆ FARM_BUILD_ZONE.
	var yard := [
		Vector2(160, 560), Vector2(1120, 560), Vector2(280, 700), Vector2(1000, 700),
	]
	for i in yard.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % ((i + 2) % 6)
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


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "âä½å®åº", SceneRouter.RESIDENTIAL_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "âå¹¿åº", SceneRouter.SQUARE_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "âåç°", SceneRouter.FARMLAND_PATH, Vector2(640, 900), Vector2(96, 56))
	craft.make_portal(ysort, "âæ»è§", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
