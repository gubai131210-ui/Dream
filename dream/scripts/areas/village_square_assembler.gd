class_name VillageSquareAssembler
extends Node

## Village square assembler — follows realistic-scene-craft skill.
## Pass: masks → ecology → water → path → buildings → props → trees → actors → FX.
## Facing: south-door art → north-of-plaza lots. Reference: A09.

const GRASS_ATLAS := "res://assets/tilesets/grass_seamless_atlas.png"
const STONE_ATLAS := "res://assets/tilesets/stone_seamless_atlas.png"
const DIRT_ATLAS := "res://assets/tilesets/dirt_seamless_atlas.png"
const WATER_ATLAS := "res://assets/tilesets/water_seamless_atlas.png"

const MAP_W := 40
const MAP_H := 30
const TILE := Scale.BASE_TILE

## Bridge band (ACNH-like span rules: prefer 3–5 water tiles).
const BRIDGE_TY0 := 14
const BRIDGE_TY1 := 15

var _water_mask: Array = []
var _bank_mask: Array = []
var _path_mask: Array = []
var _dirt_mask: Array = []


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	TileSetFactory.clear_layer(ground)
	TileSetFactory.clear_layer(path)
	TileSetFactory.clear_layer(water)

	_rebuild_masks()

	ground.tile_set = TileSetFactory.from_atlas(load(GRASS_ATLAS) as Texture2D)
	path.tile_set = TileSetFactory.from_atlas(load(STONE_ATLAS) as Texture2D)
	water.tile_set = TileSetFactory.from_atlas(load(WATER_ATLAS) as Texture2D)
	TileSetFactory.configure_layer(ground)
	TileSetFactory.configure_layer(path)
	TileSetFactory.configure_layer(water)

	# Optional dirt layer for door yards (same node stack via Ground overwrite after grass).
	_paint_ecological_grass(ground)
	_paint_dirt_spurs(ground)
	_paint_meandering_river(water, ground)
	_paint_paths(path)

	_spawn_buildings(ysort)
	_spawn_props(ysort)
	_spawn_bridge_prop(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	_spawn_water_overlay(ysort)
	_spawn_fx(ysort)


func _rebuild_masks() -> void:
	_water_mask.clear()
	_bank_mask.clear()
	_path_mask.clear()
	_dirt_mask.clear()
	for y in range(MAP_H):
		var wrow: Array = []
		var brow: Array = []
		var prow: Array = []
		var drow: Array = []
		wrow.resize(MAP_W)
		brow.resize(MAP_W)
		prow.resize(MAP_W)
		drow.resize(MAP_W)
		for x in range(MAP_W):
			wrow[x] = _compute_river_tile(x, y)
			prow[x] = false
			brow[x] = false
			drow[x] = false
		_water_mask.append(wrow)
		_path_mask.append(prow)
		_bank_mask.append(brow)
		_dirt_mask.append(drow)

	# Widen / normalize water across the bridge band so span is 3–5 tiles.
	_normalize_bridge_water()

	for y in range(MAP_H):
		for x in range(MAP_W):
			_path_mask[y][x] = _compute_path_tile(x, y)

	_paint_door_spur_masks()

	for y in range(MAP_H):
		for x in range(MAP_W):
			if _water_mask[y][x] or _path_mask[y][x] or _dirt_mask[y][x]:
				continue
			if _touches_water(x, y):
				_bank_mask[y][x] = true


func _river_center_x(ty: float) -> float:
	# Meander with less pure-period look (skill formula).
	return 4.2 + sin(ty * 0.36) * 2.35 + cos(ty * 0.17 + 0.9) * 1.4 + sin(ty * 0.09 + 0.3) * 0.85


func _river_half_width(ty: float) -> float:
	# Target ~3–5 tile corridor most of the run (ACNH river grammar).
	return 2.15 + 0.85 * sin(ty * 0.24 + 1.1) + 0.4 * cos(ty * 0.51)


func _compute_river_tile(tx: int, ty: int) -> bool:
	var cx := _river_center_x(float(ty))
	var hw := _river_half_width(float(ty))
	var dx := abs(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 1.15 and sin(ty * 0.85 + tx * 0.4) > 0.52:
		return true
	return false


func _normalize_bridge_water() -> void:
	# Ensure bridge rows have a continuous water run of 3–5 cells for a readable span.
	for ty in [BRIDGE_TY0, BRIDGE_TY1]:
		var cells: Array[int] = []
		for tx in range(MAP_W):
			if _water_mask[ty][tx]:
				cells.append(tx)
		if cells.is_empty():
			continue
		var lo: int = cells[0]
		var hi: int = cells[cells.size() - 1]
		# Fill gaps in the main cluster.
		for tx in range(lo, hi + 1):
			_water_mask[ty][tx] = true
		var width := hi - lo + 1
		if width < 3:
			var need := 3 - width
			for i in range(need):
				if hi + 1 < MAP_W:
					hi += 1
					_water_mask[ty][hi] = true
				elif lo - 1 >= 0:
					lo -= 1
					_water_mask[ty][lo] = true
		elif width > 5:
			# Trim outer edges so bridge stays 3–5.
			var excess := width - 5
			for i in range(excess):
				if i % 2 == 0:
					_water_mask[ty][lo] = false
					lo += 1
				else:
					_water_mask[ty][hi] = false
					hi -= 1


func _bridge_water_range() -> Vector2i:
	var lo := MAP_W
	var hi := -1
	for ty in [BRIDGE_TY0, BRIDGE_TY1]:
		for tx in range(MAP_W):
			if _water_mask[ty][tx]:
				lo = mini(lo, tx)
				hi = maxi(hi, tx)
	if hi < 0:
		return Vector2i(3, 7)
	return Vector2i(lo, hi)


func _compute_path_tile(tx: int, ty: int) -> bool:
	# Plaza core.
	if tx >= 14 and tx < 26 and ty >= 10 and ty < 20:
		return true
	# North approach spur (door apron for town hall — stops before building yard).
	if tx >= 18 and tx < 22 and ty >= 8 and ty < 10:
		return true
	# South arm
	if tx >= 18 and tx < 22 and ty >= 20 and ty < 28:
		return true
	# East arm
	if tx >= 26 and tx < 38 and ty >= 13 and ty < 17:
		return true
	# West arm to east bank, then bridge deck over water.
	var br := _bridge_water_range()
	if ty >= 13 and ty < 17:
		# Land approach from plaza to east bank.
		if tx >= br.y + 1 and tx < 14 and not _water_mask[ty][tx]:
			return true
		# Bridge deck exactly over water + one land anchor each side.
		if ty == BRIDGE_TY0 or ty == BRIDGE_TY1:
			if tx >= br.x - 1 and tx <= br.y + 1:
				return true
	return false


func _paint_door_spur_masks() -> void:
	# Dirt spurs: plaza → door apron (ACNH / Spiritfarer walk-line → door).
	# Tile coords match north-of-plaza building slots (south-facing doors).
	var spurs: Array[Array] = [
		# Town hall apron (north of plaza, south of building).
		[Vector2i(19, 7), Vector2i(20, 7), Vector2i(21, 7)],
		# NW house yard path from plaza NW corner.
		[Vector2i(13, 11), Vector2i(12, 11), Vector2i(11, 10), Vector2i(10, 9), Vector2i(10, 8)],
		# Cottage near hall.
		[Vector2i(14, 9), Vector2i(13, 8), Vector2i(13, 7)],
		# Church / NE approach from east arm northward.
		[Vector2i(30, 12), Vector2i(30, 11), Vector2i(30, 10), Vector2i(31, 9)],
		# East house.
		[Vector2i(33, 12), Vector2i(33, 11), Vector2i(33, 10), Vector2i(34, 9)],
	]
	for spur in spurs:
		for cell in spur:
			var c: Vector2i = cell
			if c.x < 0 or c.y < 0 or c.x >= MAP_W or c.y >= MAP_H:
				continue
			if _water_mask[c.y][c.x]:
				continue
			if _path_mask[c.y][c.x]:
				continue
			_dirt_mask[c.y][c.x] = true


func _touches_water(tx: int, ty: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			var nx := tx + ox
			var ny := ty + oy
			if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
				continue
			if _water_mask[ny][nx]:
				return true
	return false


func _is_path_tile(tx: int, ty: int) -> bool:
	return bool(_path_mask[ty][tx])


func _is_dirt_tile(tx: int, ty: int) -> bool:
	return bool(_dirt_mask[ty][tx])


func _is_river_tile(tx: int, ty: int) -> bool:
	return bool(_water_mask[ty][tx])


func _is_bank_tile(tx: int, ty: int) -> bool:
	return bool(_bank_mask[ty][tx])


func _is_walk_surface(tx: int, ty: int) -> bool:
	return _is_path_tile(tx, ty) or _is_dirt_tile(tx, ty)


func _is_plantable_land(tx: int, ty: int) -> bool:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return false
	if _is_river_tile(tx, ty):
		return false
	if _is_path_tile(tx, ty) or _is_dirt_tile(tx, ty):
		return false
	return true


func _footprint_ok(center: Vector2, half_w_tiles: int, half_h_tiles: int, allow_path: bool = false) -> bool:
	var t := _world_to_tile(center)
	for oy in range(-half_h_tiles, half_h_tiles + 1):
		for ox in range(-half_w_tiles, half_w_tiles + 1):
			var nx := t.x + ox
			var ny := t.y + oy
			if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
				return false
			if _is_river_tile(nx, ny):
				return false
			if not allow_path and (_is_path_tile(nx, ny) or _is_dirt_tile(nx, ny)):
				return false
	return true


func _find_clear_near(ideal: Vector2, half_w: int, half_h: int, max_r: int = 8, allow_path: bool = false) -> Vector2:
	if _footprint_ok(ideal, half_w, half_h, allow_path):
		return ideal
	var t := _world_to_tile(ideal)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(abs(ox), abs(oy)) != r:
					continue
				var cand := _tile_center(t.x + ox, t.y + oy)
				if _footprint_ok(cand, half_w, half_h, allow_path):
					return cand
	return Vector2.ZERO


func _world_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / float(TILE))), int(floor(pos.y / float(TILE))))


func _tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((tx + 0.5) * TILE, (ty + 0.5) * TILE)


func _paint_ecological_grass(ground: TileMapLayer) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var dist := _build_path_distance_field()
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if _is_path_tile(tx, ty) or _is_dirt_tile(tx, ty):
				continue
			var kind := "meadow"
			if _is_river_tile(tx, ty) or _is_bank_tile(tx, ty):
				kind = "damp"
			else:
				var dpath: int = dist[ty][tx]
				var edge := mini(tx, mini(ty, mini(MAP_W - 1 - tx, MAP_H - 1 - ty)))
				if dpath <= 2:
					kind = "mowed"
				elif edge <= 2 or dpath >= 8:
					kind = "tall"
				elif rng.randf() < 0.05:
					kind = "weed"
			var variants := TileSetFactory.grass_coords(kind)
			ground.set_cell(Vector2i(tx, ty), 0, variants[rng.randi_range(0, variants.size() - 1)])


func _paint_dirt_spurs(ground: TileMapLayer) -> void:
	# Door yards use dirt atlas painted onto Ground (walk line ≠ plaza stone).
	if not ResourceLoader.exists(DIRT_ATLAS):
		return
	var dirt_tex := load(DIRT_ATLAS) as Texture2D
	if dirt_tex == null:
		return
	# Temporarily swap tileset is awkward; instead stamp dirt by rebuilding a dual-source set.
	# Practical approach: create a combined TileSet once.
	var combined := _grass_with_dirt_tileset(ground.tile_set, dirt_tex)
	ground.tile_set = combined
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if not _is_dirt_tile(tx, ty):
				continue
			# source_id 1 = dirt atlas (see _grass_with_dirt_tileset).
			ground.set_cell(Vector2i(tx, ty), 1, Vector2i(rng.randi_range(0, 1), 0))


func _grass_with_dirt_tileset(grass_ts: TileSet, dirt_tex: Texture2D) -> TileSet:
	var ts := grass_ts
	# If dirt source already present, reuse.
	if ts.get_source_count() >= 2:
		return ts
	var src := TileSetAtlasSource.new()
	src.texture = dirt_tex
	src.texture_region_size = Vector2i(TILE, TILE)
	src.use_texture_padding = true
	for y in range(dirt_tex.get_height() / TILE):
		for x in range(dirt_tex.get_width() / TILE):
			src.create_tile(Vector2i(x, y))
	ts.add_source(src, 1)
	return ts


func _build_path_distance_field() -> Array:
	var dist: Array = []
	var queue: Array[Vector2i] = []
	for y in range(MAP_H):
		var row: Array = []
		row.resize(MAP_W)
		for x in range(MAP_W):
			if _is_walk_surface(x, y):
				row[x] = 0
				queue.append(Vector2i(x, y))
			else:
				row[x] = 999
		dist.append(row)
	var head := 0
	while head < queue.size():
		var p: Vector2i = queue[head]
		head += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = p + d
			if n.x < 0 or n.y < 0 or n.x >= MAP_W or n.y >= MAP_H:
				continue
			var nd: int = int(dist[p.y][p.x]) + 1
			if nd < int(dist[n.y][n.x]):
				dist[n.y][n.x] = nd
				queue.append(n)
	return dist


func _paint_paths(path: TileMapLayer) -> void:
	var stone: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if not _is_path_tile(tx, ty):
				continue
			path.set_cell(Vector2i(tx, ty), 0, stone[rng.randi_range(0, stone.size() - 1)])


func _paint_meandering_river(water: TileMapLayer, ground: TileMapLayer) -> void:
	var water_vars: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	var damp := TileSetFactory.grass_coords("damp")
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if _is_river_tile(tx, ty):
				if _is_path_tile(tx, ty):
					continue
				water.set_cell(Vector2i(tx, ty), 0, water_vars[rng.randi_range(0, water_vars.size() - 1)])
			elif _is_bank_tile(tx, ty):
				ground.set_cell(Vector2i(tx, ty), 0, damp[rng.randi_range(0, damp.size() - 1)])


func _spawn_sprite(parent: Node2D, path: String, pos: Vector2, z: int = 0) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = load(path) as Texture2D
	spr.position = pos
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = z
	parent.add_child(spr)
	return spr


func _add_contact_shadow(parent: Node2D, at: Vector2, radius: Vector2 = Vector2(18, 8)) -> void:
	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.28)
	shadow.polygon = PackedVector2Array([
		Vector2(-radius.x, 0),
		Vector2(0, -radius.y),
		Vector2(radius.x, 0),
		Vector2(0, radius.y),
	])
	shadow.position = at + Vector2(0, 10)
	shadow.z_index = -1
	parent.add_child(shadow)


func _make_hotspot(parent: Node2D, title: String, desc: String, pos: Vector2, size: Vector2) -> InteractableHotspot:
	var hs := InteractableHotspot.new()
	hs.name = title.replace(" ", "")
	hs.title = title
	hs.description = desc
	hs.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	hs.add_child(visual)
	parent.add_child(hs)
	return hs


func _spawn_buildings(ysort: Node2D) -> void:
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(640, 150),
			"hw": 3, "hh": 2,
			"title": "村公所",
			"desc": "广场北侧主建筑：门脸朝南，门前石路/土路接到广场。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(1000, 220),
			"hw": 3, "hh": 2,
			"title": "教堂",
			"desc": "广场东北公共建筑，东臂道路北上的门前小路。",
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(300, 220),
			"hw": 3, "hh": 2,
			"title": "西侧住宅",
			"desc": "河东岸西北民居；门朝南，土路连向广场。",
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(1080, 240),
			"hw": 3, "hh": 2,
			"title": "东侧住宅",
			"desc": "东北民居，门脸朝南。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(420, 220),
			"hw": 2, "hh": 2,
			"title": "北侧小屋",
			"desc": "村公所旁附属小屋。",
		},
	]
	for s in specs:
		var pos: Vector2 = s["pos"]
		var cleared := _find_clear_near(pos, int(s["hw"]), int(s["hh"]), 10, false)
		if cleared == Vector2.ZERO:
			continue
		pos = cleared
		_add_contact_shadow(ysort, pos, Vector2(36, 12))
		var spr := _spawn_sprite(ysort, s["path"], pos)
		# South edge of footprint drives perceived facing / Y order.
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		var hs := _make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	var well_path := "res://assets/sprites/props/plaza_fountain.png"
	if not ResourceLoader.exists(well_path):
		well_path = "res://assets/sprites/props/fountain.png"
	if ResourceLoader.exists(well_path):
		_add_contact_shadow(ysort, Vector2(640, 480), Vector2(28, 10))
		var f := _spawn_sprite(ysort, well_path, Vector2(640, 480))
		var hs := _make_hotspot(ysort, "水井", "广场中央石井（A09 喷泉区位）。", Vector2(640, 500), Vector2(96, 64))
		f.reparent(hs.get_node("Visual"))
		f.position = Vector2.ZERO

	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(500, 430), "title": "木桶", "desc": "摊位旁木桶。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(780, 430), "title": "货箱", "desc": "市场货箱。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(560, 540), "title": "长椅", "desc": "面向水井的长椅。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(720, 540), "title": "路灯", "desc": "广场路灯。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(360, 300), "title": "麻袋", "desc": "屋前草地麻袋。", "on_path_ok": false, "hw": 1, "hh": 1},
	]
	for s in samples:
		var pos: Vector2 = s["pos"]
		if s["on_path_ok"]:
			if _is_river_tile(_world_to_tile(pos).x, _world_to_tile(pos).y):
				continue
		else:
			var cleared := _find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, false)
			if cleared == Vector2.ZERO:
				continue
			pos = cleared
		if not ResourceLoader.exists(s["path"]):
			continue
		_add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := _spawn_sprite(ysort, s["path"], pos)
		var hs := _make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_bridge_prop(ysort: Node2D) -> void:
	# Landmark on the authored bridge band (deck is path tiles; prop sells the crossing).
	var br := _bridge_water_range()
	var mid_x := int((br.x + br.y) * 0.5)
	var pos := _tile_center(mid_x, BRIDGE_TY0)
	var hs := _make_hotspot(
		ysort,
		"木桥",
		"西河桥跨：水面宽度约 3–5 格，两岸留锚点，石板铺面跨水。",
		pos,
		Vector2(96, 48)
	)
	# Simple plank readout if no bridge sprite: tinted stone strip already on Path.
	var label_proxy := ColorRect.new()
	label_proxy.size = Vector2(72, 18)
	label_proxy.position = Vector2(-36, -8)
	label_proxy.color = Color(0.45, 0.32, 0.18, 0.55)
	hs.get_node("Visual").add_child(label_proxy)


func _spawn_trees(ysort: Node2D) -> void:
	var ideals := [
		Vector2(220, 120),
		Vector2(380, 100),
		Vector2(240, 400),
		Vector2(260, 700),
		Vector2(1100, 120),
		Vector2(1140, 400),
		Vector2(1100, 700),
		Vector2(860, 760),
		Vector2(180, 560),
		Vector2(200, 300),
	]
	for i in ideals.size():
		var pos := _find_clear_near(ideals[i], 1, 1, 8, false)
		if pos == Vector2.ZERO:
			continue
		var t := _world_to_tile(pos)
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		_add_contact_shadow(ysort, pos, Vector2(22, 8))
		var spr := _spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)
		if _is_bank_tile(t.x, t.y) or _touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_actors(ysort: Node2D) -> void:
	# Sparse anchors on stone preference graph (Stardew-like schedules).
	var actors := [
		{
			"path": "res://assets/sprites/npc/npc_00.png",
			"title": "村民",
			"desc": "在井边与长椅之间走动。",
			"waypoints": [Vector2(600, 520), Vector2(560, 540), Vector2(640, 500), Vector2(600, 520)],
		},
		{
			"path": "res://assets/sprites/npc/npc_01.png",
			"title": "摊主",
			"desc": "守着东侧摊位一带。",
			"waypoints": [Vector2(720, 500), Vector2(780, 430), Vector2(720, 460), Vector2(720, 500)],
		},
		{
			"path": "res://assets/sprites/npc/npc_02.png",
			"title": "访客",
			"desc": "沿广场石路环行。",
			"waypoints": [Vector2(540, 480), Vector2(700, 480), Vector2(700, 560), Vector2(540, 560), Vector2(540, 480)],
		},
	]
	for a in actors:
		if not ResourceLoader.exists(a["path"]):
			continue
		var start: Vector2 = a["waypoints"][0]
		# Snap start onto walk surface when possible.
		var st := _world_to_tile(start)
		if not _is_walk_surface(st.x, st.y):
			var snapped := _find_walk_near(start, 6)
			if snapped != Vector2.ZERO:
				start = snapped
		var hs := _make_hotspot(ysort, a["title"], a["desc"], start, Vector2(40, 56))
		var visual: Node2D = hs.get_node("Visual")
		_add_contact_shadow(visual, Vector2(0, 0), Vector2(12, 5))
		var spr := _spawn_sprite(visual, a["path"], Vector2.ZERO)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		_animate_patrol(hs, a["waypoints"])


func _find_walk_near(ideal: Vector2, max_r: int) -> Vector2:
	var t := _world_to_tile(ideal)
	if _is_walk_surface(t.x, t.y):
		return _tile_center(t.x, t.y)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(abs(ox), abs(oy)) != r:
					continue
				var nx := t.x + ox
				var ny := t.y + oy
				if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
					continue
				if _is_walk_surface(nx, ny):
					return _tile_center(nx, ny)
	return Vector2.ZERO


func _animate_patrol(node: Node2D, waypoints: Array) -> void:
	if waypoints.size() < 2:
		return
	var tw := node.create_tween().set_loops()
	for i in range(1, waypoints.size()):
		var target: Vector2 = waypoints[i]
		var t := _world_to_tile(target)
		if not _is_walk_surface(t.x, t.y) and not _is_path_tile(t.x, t.y):
			# Prefer stone; allow plaza-adjacent if marked path in mask rebuild.
			pass
		var dist := node.position.distance_to(target)
		var dur := clampf(dist / 40.0, 1.2, 4.0)
		tw.tween_property(node, "position", target, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(0.35)


func _spawn_water_overlay(ysort: Node2D) -> void:
	# Stardew-like shared shimmer: cycle atlas frames on water cells (checkerboard phase).
	if not ResourceLoader.exists(WATER_ATLAS):
		return
	var atlas := load(WATER_ATLAS) as Texture2D
	if atlas == null:
		return
	var overlay := Node2D.new()
	overlay.name = "WaterOverlay"
	overlay.z_index = 1
	ysort.add_child(overlay)
	var frames: Array[AtlasTexture] = []
	for i in range(3):
		var at := AtlasTexture.new()
		at.atlas = atlas
		at.region = Rect2(i * TILE, 0, TILE, TILE)
		frames.append(at)
	var idx := 0
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if not _is_river_tile(tx, ty):
				continue
			if _is_path_tile(tx, ty):
				continue
			var spr := Sprite2D.new()
			spr.texture = frames[(tx + ty) % frames.size()]
			spr.position = _tile_center(tx, ty)
			spr.modulate = Color(1, 1, 1, 0.42)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			overlay.add_child(spr)
			var phase := 0.2 * float((tx + ty) % 4)
			var tw := spr.create_tween().set_loops()
			tw.tween_interval(phase)
			tw.tween_property(spr, "modulate:a", 0.22, 0.9).set_trans(Tween.TRANS_SINE)
			tw.tween_property(spr, "modulate:a", 0.5, 0.9).set_trans(Tween.TRANS_SINE)
			# Swap frame every ~0.6s via callback chain.
			var frame_i := (tx + ty) % frames.size()
			spr.set_meta("frame_i", frame_i)
			spr.set_meta("frames", frames)
			idx += 1
			if idx > 80:
				# Cap overlay sprites for performance on large rivers.
				return
	_start_water_frame_ticker(overlay)


func _start_water_frame_ticker(overlay: Node2D) -> void:
	var timer := Timer.new()
	timer.wait_time = 0.2
	timer.autostart = true
	overlay.add_child(timer)
	timer.timeout.connect(func():
		for c in overlay.get_children():
			if c is Sprite2D and c.has_meta("frames"):
				var frames: Array = c.get_meta("frames")
				var fi: int = int(c.get_meta("frame_i"))
				fi = (fi + 1) % frames.size()
				c.set_meta("frame_i", fi)
				(c as Sprite2D).texture = frames[fi]
	)


func _spawn_fx(_ysort: Node2D) -> void:
	pass
