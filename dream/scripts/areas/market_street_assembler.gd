class_name MarketStreetAssembler
extends Node

## Market street / commercial plaza (A10) — AreaCraft masks + layered assemble.
## Stone market plaza + stalls (not a fountain square). Shops north/east, south-facing.
## Reference craft: A10_commercial_street / A10_market_street (do not paste as background).

const MAP_W := 40
const MAP_H := 30

## Short west meander bridge band (optional river; keep narrow so plaza fits).
const BRIDGE_TY0 := 14
const BRIDGE_TY1 := 15

## Door dirt south of north shop footprints (clear of half_h around foot ~ ty 9).
const DOOR_LANE_TY0 := 10
const DOOR_LANE_TY1 := 11

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
	_spawn_market_stalls(ysort)
	_spawn_plaza_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_river_tile(x, y)

	_normalize_bridge_water()
	_paint_stone_plaza_and_arms()
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
	# Confine river to mid-west band so plaza / east shops stay dry.
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


func _paint_stone_plaza_and_arms() -> void:
	# Central cobble market plaza (reference A10 stone core).
	_fill_path_rect(14, 12, 26, 20)
	# West arm to bridge + east bank approach.
	var br := _bridge_water_range()
	for ty in range(14, 17):
		for tx in range(br.y + 1, 14):
			if not craft.is_water(tx, ty):
				_set_path(tx, ty)
		if ty == BRIDGE_TY0 or ty == BRIDGE_TY1:
			for tx in range(br.x - 1, br.y + 2):
				if tx >= 0 and tx < MAP_W:
					_set_path(tx, ty)
	# East stone spur toward east shops.
	_fill_path_rect(26, 14, 34, 17)
	# North stone apron (stops before door dirt lane under feet).
	_fill_path_rect(18, 11, 22, 11)


func _paint_dirt_approaches() -> void:
	# Door lanes south of north shop feet — not under footprints.
	_fill_dirt_rect(16, DOOR_LANE_TY0, 24, DOOR_LANE_TY1)
	_fill_dirt_rect(28, DOOR_LANE_TY0, 33, DOOR_LANE_TY1)
	# South dirt approach to plaza.
	_fill_dirt_rect(18, 21, 22, 28)
	# East dirt approach beyond stone spur.
	_fill_dirt_rect(34, 14, 38, 17)
	# NW dirt from plaza toward west shops / river bank.
	_fill_dirt_rect(10, 11, 13, 13)
	_fill_dirt_rect(11, 8, 12, 10)
	# NE dirt to east shop front.
	_fill_dirt_rect(30, 11, 33, 13)


func _spawn_buildings(ysort: Node2D) -> void:
	# South-facing shops: north of plaza + one east lot. Full AABB ⊆ play rect.
	var zone := craft.map_play_rect(1.5)
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(640, 300),
			"hw": 2, "hh": 1,
			"title": "市集主铺",
			"desc": "广场北侧主商铺：整栋在区内，门脸朝南对市集。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(980, 300),
			"hw": 2, "hh": 1,
			"title": "东侧商铺",
			"desc": "东北商铺，门脸朝南。",
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(1100, 420),
			"hw": 2, "hh": 1,
			"title": "街角店",
			"desc": "广场东侧街角店，整栋在 play zone 内。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(420, 300),
			"hw": 2, "hh": 1,
			"title": "西侧货栈",
			"desc": "河东岸西侧货栈，门脸朝南。",
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
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_market_stalls(ysort: Node2D) -> void:
	# ≥4 stalls on stone plaza: crates/barrels/benches + striped ColorRect awnings.
	var stalls := [
		{
			"pos": Vector2(500, 448),
			"title": "蔬果摊",
			"desc": "西侧蔬果摊：货箱与红白条纹棚。",
			"crate": "res://assets/sprites/props/crate_0.png",
			"barrel": "res://assets/sprites/props/barrel_0.png",
			"stripe_a": Color(0.85, 0.2, 0.2, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
		},
		{
			"pos": Vector2(640, 464),
			"title": "双联摊",
			"desc": "市集中央双联摊：货箱与蓝白棚。",
			"crate": "res://assets/sprites/props/crate_1.png",
			"barrel": "res://assets/sprites/props/barrel_1.png",
			"stripe_a": Color(0.2, 0.45, 0.85, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
		},
		{
			"pos": Vector2(780, 448),
			"title": "百货摊",
			"desc": "东侧百货摊：木箱与条纹棚。",
			"crate": "res://assets/sprites/props/crate_2.png",
			"barrel": "res://assets/sprites/props/barrel_2.png",
			"stripe_a": Color(0.85, 0.2, 0.2, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
		},
		{
			"pos": Vector2(580, 560),
			"title": "南口摊",
			"desc": "南口长椅旁摊位。",
			"crate": "res://assets/sprites/props/crate_0.png",
			"barrel": "res://assets/sprites/props/barrel_0.png",
			"stripe_a": Color(0.2, 0.55, 0.35, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.9, 0.92),
		},
		{
			"pos": Vector2(720, 560),
			"title": "灯下摊",
			"desc": "广场南缘灯旁小摊。",
			"crate": "res://assets/sprites/props/crate_1.png",
			"barrel": "res://assets/sprites/props/sack_0.png",
			"stripe_a": Color(0.75, 0.45, 0.15, 0.92),
			"stripe_b": Color(0.95, 0.92, 0.85, 0.92),
		},
	]
	for s in stalls:
		var pos: Vector2 = s["pos"]
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(88, 64))
		var visual: Node2D = hs.get_node("Visual")
		craft.add_contact_shadow(visual, Vector2(0, 0), Vector2(28, 10))
		_add_awning(visual, s["stripe_a"], s["stripe_b"])
		if ResourceLoader.exists(s["crate"]):
			var c := craft.spawn_sprite(visual, s["crate"], Vector2(-14, 6))
			c.z_index = 1
		if ResourceLoader.exists(s["barrel"]):
			var b := craft.spawn_sprite(visual, s["barrel"], Vector2(16, 8))
			b.z_index = 1
		if ResourceLoader.exists("res://assets/sprites/props/bench_0.png"):
			var bench := craft.spawn_sprite(visual, "res://assets/sprites/props/bench_0.png", Vector2(0, 18))
			bench.z_index = 0
			bench.modulate = Color(1, 1, 1, 0.95)


func _add_awning(parent: Node2D, color_a: Color, color_b: Color) -> void:
	# Striped awning proxy (ColorRect strips) — matches A10 stall look without unique art.
	var awning := Node2D.new()
	awning.name = "Awning"
	awning.position = Vector2(-36, -28)
	parent.add_child(awning)
	var stripe_w := 12.0
	var h := 18.0
	for i in range(6):
		var strip := ColorRect.new()
		strip.size = Vector2(stripe_w, h)
		strip.position = Vector2(float(i) * stripe_w, 0)
		strip.color = color_a if i % 2 == 0 else color_b
		awning.add_child(strip)
	var pole_l := ColorRect.new()
	pole_l.size = Vector2(3, 26)
	pole_l.position = Vector2(2, 14)
	pole_l.color = Color(0.35, 0.22, 0.12, 0.9)
	awning.add_child(pole_l)
	var pole_r := ColorRect.new()
	pole_r.size = Vector2(3, 26)
	pole_r.position = Vector2(67, 14)
	pole_r.color = Color(0.35, 0.22, 0.12, 0.9)
	awning.add_child(pole_r)


func _spawn_plaza_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(460, 400), "title": "西灯", "desc": "市集西角路灯。", "on_path": true},
		{"path": "res://assets/sprites/props/lamp_1.png", "pos": Vector2(820, 400), "title": "东灯", "desc": "市集东角路灯。", "on_path": true},
		{"path": "res://assets/sprites/props/lamp_2.png", "pos": Vector2(460, 620), "title": "南灯", "desc": "南口路灯。", "on_path": true},
		{"path": "res://assets/sprites/props/bench_1.png", "pos": Vector2(540, 520), "title": "长椅", "desc": "面向摊位的长椅。", "on_path": true},
		{"path": "res://assets/sprites/props/bench_2.png", "pos": Vector2(740, 520), "title": "歇脚椅", "desc": "东摊旁歇脚椅。", "on_path": true},
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(360, 360), "title": "麻袋", "desc": "货栈前麻袋。", "on_path": false},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		if s["on_path"]:
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
		else:
			var cleared := craft.find_clear_near(pos, 1, 1, 6, false)
			if cleared == Vector2.ZERO:
				continue
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO

	# Bridge landmark on west span.
	var br := _bridge_water_range()
	var mid_x := int((br.x + br.y) * 0.5)
	var bpos := craft.tile_center(mid_x, BRIDGE_TY0)
	var bhs := craft.make_hotspot(
		ysort,
		"市集桥",
		"西河短跨：石板桥面连向广场西臂。",
		bpos,
		Vector2(96, 48)
	)
	var plank := ColorRect.new()
	plank.size = Vector2(72, 18)
	plank.position = Vector2(-36, -8)
	plank.color = Color(0.45, 0.32, 0.18, 0.55)
	bhs.get_node("Visual").add_child(plank)


func _spawn_trees(ysort: Node2D) -> void:
	var ideals := [
		Vector2(180, 100), Vector2(240, 200), Vector2(200, 700),
		Vector2(1120, 100), Vector2(1180, 280), Vector2(1160, 700),
		Vector2(400, 100), Vector2(860, 100),
		Vector2(200, 500), Vector2(1000, 760),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 8, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(22, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)
		if craft.is_bank(t.x, t.y) or craft.touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_actors(ysort: Node2D) -> void:
	var actors := [
		{
			"path": "res://assets/sprites/npc/npc_00.png",
			"title": "摊主",
			"desc": "在中央双联摊与货箱之间忙碌。",
			"waypoints": [
				Vector2(640, 464),
				Vector2(700, 480),
				Vector2(580, 480),
				Vector2(640, 464),
			],
		},
		{
			"path": "res://assets/sprites/npc/npc_01.png",
			"title": "买手",
			"desc": "沿石板市集逛摊。",
			"waypoints": [
				Vector2(500, 480),
				Vector2(640, 520),
				Vector2(780, 480),
				Vector2(640, 440),
				Vector2(500, 480),
			],
		},
		{
			"path": "res://assets/sprites/npc/npc_02.png",
			"title": "访客",
			"desc": "从南口土路走进市集。",
			"waypoints": [
				Vector2(640, 820),
				Vector2(640, 700),
				Vector2(640, 560),
				Vector2(720, 520),
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
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→住宅区", SceneRouter.RESIDENTIAL_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
