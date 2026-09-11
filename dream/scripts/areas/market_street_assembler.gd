class_name MarketStreetAssembler
extends Node

## Market street / commercial lane (A10) — AreaCraft masks + layered assemble.
## District: market (AREA_FRAMEWORK). craft.setup(..., "market").
## Elongated E–W cobble street + shallow stall alcoves (not a fountain square).
## Shops flank the street (north + one east), south-facing.
## Reference craft: A10_commercial_street / A10_market_street (do not paste as background).

const MAP_W := 40
const MAP_H := 30

## Short west meander bridge band (optional river; keep narrow so street fits).
const BRIDGE_TY0 := 14
const BRIDGE_TY1 := 15

## Door dirt south of north shop footprints (clear of half_h around foot ~ ty 9).
const DOOR_LANE_TY0 := 10
const DOOR_LANE_TY1 := 11

## East shop door dirt (foot ~ ty 12, south of half_h only).
const EAST_DOOR_TY0 := 13
const EAST_DOOR_TY1 := 14

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H, "market")
	_rebuild_masks()
	craft.prepare_layers(ground, path, water)

	craft.paint_ecological_grass(ground)
	craft.paint_dirt_spurs(ground)
	craft.paint_water(water, ground)
	craft.paint_paths(path)

	_spawn_buildings(ysort)
	var dressing := MarketStreetDressing.new()
	dressing.craft = craft
	dressing.spawn_all(ysort)
	_spawn_trees(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_river_tile(x, y)

	_normalize_bridge_water()
	_paint_stone_street_and_arms()
	_paint_dirt_approaches()
	# Paths/dirt punch water (bridge deck stays path over water).
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				if not _is_bridge_deck(x, y):
					craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _river_center_x(ty: float) -> float:
	# Short west-edge meander — not a full-height canal.
	return 3.4 + sin(ty * 0.42) * 1.55 + cos(ty * 0.19 + 0.7) * 0.9


func _river_half_width(ty: float) -> float:
	return 1.55 + 0.45 * sin(ty * 0.31 + 0.8)


func _compute_river_tile(tx: int, ty: int) -> bool:
	# Confine river to mid-west band so street / east shops stay dry.
	if ty < 6 or ty > 24:
		return false
	if tx > 8:
		return false
	var cx: float = _river_center_x(float(ty))
	var hw: float = _river_half_width(float(ty))
	var dx: float = absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 0.85 and sin(float(ty) * 0.9 + float(tx) * 0.5) > 0.55:
		return true
	return false


func _normalize_bridge_water() -> void:
	for ty in [BRIDGE_TY0, BRIDGE_TY1]:
		var best_lo := -1
		var best_hi := -1
		var best_len := 0
		var run_lo := -1
		for tx in range(MAP_W + 1):
			var wet := tx < MAP_W and bool(craft.water_mask[ty][tx])
			if wet:
				if run_lo < 0:
					run_lo = tx
			elif run_lo >= 0:
				var run_hi := tx - 1
				var run_len := run_hi - run_lo + 1
				if run_len > best_len:
					best_len = run_len
					best_lo = run_lo
					best_hi = run_hi
				run_lo = -1
		if best_lo < 0:
			continue
		var lo := best_lo
		var hi := best_hi
		var width := hi - lo + 1
		if width < 3:
			var need := 3 - width
			for _i in range(need):
				if hi + 1 < 9:
					hi += 1
					craft.water_mask[ty][hi] = true
				elif lo - 1 >= 0:
					lo -= 1
					craft.water_mask[ty][lo] = true
		elif width > 5:
			var excess := width - 5
			for i in range(excess):
				if i % 2 == 0:
					craft.water_mask[ty][lo] = false
					lo += 1
				else:
					craft.water_mask[ty][hi] = false
					hi -= 1


func _bridge_water_range() -> Vector2i:
	var lo := MAP_W
	var hi := -1
	for ty in [BRIDGE_TY0, BRIDGE_TY1]:
		for tx in range(mini(9, MAP_W)):
			if craft.is_water(tx, ty):
				lo = mini(lo, tx)
				hi = maxi(hi, tx)
	if hi < 0:
		return Vector2i(2, 5)
	return Vector2i(lo, hi)


func _is_bridge_deck(tx: int, ty: int) -> bool:
	if ty != BRIDGE_TY0 and ty != BRIDGE_TY1:
		return false
	var br := _bridge_water_range()
	return tx >= br.x - 1 and tx <= br.y + 1


func _set_path(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.path_mask[ty][tx] = true
	craft.dirt_mask[ty][tx] = false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if craft.is_water(tx, ty) and not _is_bridge_deck(tx, ty):
		return
	if craft.is_path(tx, ty):
		return
	craft.dirt_mask[ty][tx] = true


func _fill_path_rect(x0: int, y0: int, x1: int, y1: int) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_path(tx, ty)


func _fill_dirt_rect(x0: int, y0: int, x1: int, y1: int) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_dirt(tx, ty)


func _paint_stone_street_and_arms() -> void:
	# Long E–W commercial cobble (narrow N–S — not a centered plaza).
	_fill_path_rect(10, 14, 34, 17)
	# West arm / bridge deck over river.
	var br := _bridge_water_range()
	for ty in range(14, 17):
		for tx in range(br.y + 1, 10):
			if not craft.is_water(tx, ty):
				_set_path(tx, ty)
		if ty == BRIDGE_TY0 or ty == BRIDGE_TY1:
			for tx in range(br.x - 1, br.y + 2):
				if tx >= 0 and tx < MAP_W:
					_set_path(tx, ty)
	# Shallow stall alcoves north of street (path pockets).
	_fill_path_rect(14, 12, 17, 13)  # NW alcove
	_fill_path_rect(22, 12, 25, 13)  # N mid alcove
	_fill_path_rect(29, 12, 32, 13)  # NE alcove
	# Shallow stall alcoves south of street (path + dirt pocket mix).
	_fill_path_rect(16, 18, 19, 19)  # SW alcove
	_fill_path_rect(24, 18, 27, 19)  # S mid alcove
	# East spur already covered by main strip to tx 34; slight nose beyond shops.
	_fill_path_rect(34, 14, 35, 16)


func _paint_dirt_approaches() -> void:
	# Door lanes south of north shop feet — not under footprints.
	_fill_dirt_rect(12, DOOR_LANE_TY0, 16, DOOR_LANE_TY1)  # west shop
	_fill_dirt_rect(18, DOOR_LANE_TY0, 24, DOOR_LANE_TY1)  # main shop
	_fill_dirt_rect(26, DOOR_LANE_TY0, 30, DOOR_LANE_TY1)  # NE shop
	# East street-flank shop door dirt (south of foot only).
	_fill_dirt_rect(32, EAST_DOOR_TY0, 35, EAST_DOOR_TY1)
	# Narrow south dirt approach (not a plaza apron).
	_fill_dirt_rect(19, 20, 21, 28)
	# East dirt beyond stone spur.
	_fill_dirt_rect(35, 14, 38, 17)
	# South alcove dirt pocket (stall bay, not open square).
	_fill_dirt_rect(28, 18, 31, 19)
	# NW dirt from street toward river bank / west shop.
	_fill_dirt_rect(10, 11, 13, 13)
	_fill_dirt_rect(11, 8, 12, 10)


func _spawn_buildings(ysort: Node2D) -> void:
	# South-facing shops: north of street + one east flank. Full AABB ⊆ play rect.
	# Phase 5 Wave A: three distinct C04 shop interiors (door-foot portals only).
	var zone := craft.map_play_rect(1.5)
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(672, 296),  # ~tx 21, ty 9 — north of street mid
			"hw": 2, "hh": 1,
			"title": "杂货店",
			"desc": "商业街北侧杂货店：门脸朝南对 cobble 街面。",
			"enter_title": "进入杂货店",
			"interior": SceneRouter.C04_GROCERY_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(896, 296),  # ~tx 28, ty 9 — north-east flank
			"hw": 2, "hh": 1,
			"title": "铁匠铺",
			"desc": "北排东铁匠铺，门脸朝南对街。",
			"enter_title": "进入铁匠铺",
			"interior": SceneRouter.C04_SMITH_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(1088, 400),  # ~tx 34, ty 12 — east of street, south-facing
			"hw": 2, "hh": 1,
			"title": "酒馆",
			"desc": "商业街东翼街角酒馆，整栋在 play zone 内。",
			"enter_title": "进入酒馆",
			"interior": SceneRouter.C04_TAVERN_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(448, 296),  # ~tx 14, ty 9 — north-west flank
			"hw": 2, "hh": 1,
			"title": "西侧货栈",
			"desc": "河东岸西侧货栈，门脸朝南对街（市场后台卸货）。",
			"enter_title": "进入市场后台",
			"interior": SceneRouter.C32_MARKET_BACK_PATH,
		},
	]
	for s in specs:
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_building_inside(
			pos, tex, offset, zone, int(s["hw"]), int(s["hh"]), 16, true
		)
		if cleared == Vector2.ZERO:
			push_warning("MarketStreet: could not place %s fully inside play zone" % s["title"])
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(36, 12))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.offset = offset
		craft.mark_blocked_footprint(pos, int(s["hw"]), int(s["hh"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		# Enter portal only at door feet — silhouette stays street-facing.
		if s.has("interior"):
			craft.make_portal(
				ysort,
				str(s["enter_title"]),
				str(s["interior"]),
				pos + Vector2(0, 26),
				Vector2(88, 48)
			)


func _spawn_trees(ysort: Node2D) -> void:
	# Frame street edges / alcoves — full crown AABB (no footprint-only).
	var zone := craft.map_play_rect(2.0)
	var ideals := [
		# West river / bridge approach
		Vector2(180, 120), Vector2(200, 360), Vector2(160, 560),
		# North of street (behind shops / alcove gaps)
		Vector2(360, 180), Vector2(560, 160), Vector2(760, 180), Vector2(960, 160),
		# South edge of cobble + alcoves
		Vector2(480, 640), Vector2(640, 660), Vector2(800, 640), Vector2(960, 680),
		# East beyond spur
		Vector2(1160, 280), Vector2(1180, 520), Vector2(1120, 720),
		# Far south / corners (lighter framing)
		Vector2(240, 760), Vector2(1040, 100),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)
		if spr == null:
			continue
		var t := craft.world_to_tile(spr.position)
		if craft.is_bank(t.x, t.y) or craft.touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→住宅区", SceneRouter.RESIDENTIAL_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
	# Wave D: night bazaar alley + craft workshop annex (door feet, not InfoPanel-only).
	craft.make_portal(
		ysort, "进入夜市", SceneRouter.C33_NIGHT_MARKET_PATH, Vector2(640, 560), Vector2(100, 52)
	)
	craft.make_portal(
		ysort, "进入工坊", SceneRouter.C38_WORKSHOP_PATH, Vector2(980, 320), Vector2(88, 48)
	)
	# Wave F
	craft.make_portal(ysort, "进入旅馆", SceneRouter.C44_INN_PATH, Vector2(200, 400), Vector2(100, 52))
